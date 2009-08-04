/*
 * Copyright (C) 2009 Jens Georg <mail@jensge.org>
 *
 * This file is part of pmp.
 *
 * Pmp is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Rygel is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */


using Gtk;
using Pmp;
using Soup;
using Xml;

string mode;
string name;
string uri;
bool create_desktop;
string icon_file;
MainLoop loop;
Message msg;
Message msg2;

const OptionEntry[] options = {
    { "mode", 'm', 0, OptionArg.STRING, ref mode, "mode to run pmp in (create, run, delete, list, gui)", "MODE" },
    { "name", 'n', 0, OptionArg.STRING, ref name, "name of edge", "NAME" },
    { null }
};

const OptionEntry[] create_options = {
    { "uri", 'u', 0, OptionArg.STRING, ref uri, "uri of the website to edge", "URI" },
    { "desktop", 'd', 0, OptionArg.NONE, ref create_desktop, "create desktop entry", null },
    { "icon", 'i', 0, OptionArg.FILENAME, ref icon_file, "use ICON as icon (use :favicon for the site's favicon", "ICON" },
    { null }
};

void on_favicon_done(Session session, Message message) {
    if (message.status_code == 200) {
        var f = File.new_for_path ("/tmp/favicon.ico");
        f.replace_contents (message.response_body.data,
                            (size_t)message.response_body.length,
                            null,
                            false,
                            FileCreateFlags.PRIVATE,
                            null,
                            null);
    }
    loop.quit();
}

void on_message_done (Session session, Message message) {
    if (message.status_code != 200) {
        warning ("Failed to access uri %s: %s",
                 message.uri.to_string(false),
                 message.reason_phrase);
        loop.quit();
        return;
    }
    unowned MessageBody body = message.response_body;
    MatchInfo mi;
    var fav_re = new Regex
            ("<link\\s+rel\\s*=\\s*\"(shortcut )?icon[^>]+>",
             RegexCompileFlags.CASELESS);
    if (fav_re.match (body.data, RegexMatchFlags.ANCHORED, out mi)) {
        var icon = mi.fetch (0);
        if (!icon.has_suffix ("/>")) {
            icon += "</link>";
        }

        Doc *doc = Parser.parse_doc (icon);
        if (doc != null) {
            Xml.Node *node = doc->get_root_element ();
            if (node != null) {
                Attr *attr = node->has_prop("href");
                if (attr != null) {
                    msg2 = new Message ("GET", attr->children->content);
                    debug ("Trying to download %s", attr->children->content);
                    session.queue_message ((owned)msg2, on_favicon_done);
                    return;
                }
            }

            delete doc;
        }
    }
    else {
        debug("No special favicon link found");
        var s = message.uri.to_string(false);
        var t = message.uri.to_string(true);
        string new_uri;
        if (t != "/") {
            new_uri = s.replace(t, "") + "/favicon.ico";
        }
        else {
            new_uri = s + "favicon.ico";
        }
        msg2 = new Message ("GET", new_uri);
        debug ("Trying to download %s", new_uri);
        session.queue_message ((owned)msg2, on_favicon_done);
        return;
    }
    loop.quit();
}

int main(string[] args) {
    var opt_ctx = new OptionContext("- Poor man's prism");
    opt_ctx.set_help_enabled (true);
    opt_ctx.add_main_entries (options, null);
    opt_ctx.add_group(Gtk.get_option_group (true));

    OptionGroup option_group = new OptionGroup("create", "Options in create mode",
            "Options for creating edges", null, null);
    option_group.add_entries(create_options);
    opt_ctx.add_group((owned)option_group);
    try {
        opt_ctx.parse (ref args);

        switch (mode) {
            case "create":
                if (name != null) {
                    if (uri != null) {
                        var edge = new Edge(name);
                        edge.set_uri (uri);
                        if (icon_file != null) {
                            if (icon_file == ":favicon") {
                                var session = new SessionSync ();
                                msg = new Message ("GET", uri);
                                session.queue_message ((owned)msg, on_message_done);
                                loop = new MainLoop (null, false);
                                loop.run();
                            }
                        }
                        try {
                            edge.save ();
                        } catch (GLib.Error err) {
                            print("Error: Failed to save edge: %s\n",
                                err.message);
                        }
                    }
                    else {
                        print("Error: No uri given\n");
                    }
                }
                else {
                    print("Error: No name given\n");
                }
                break;
            case "run":
                var edge = new Edge(name);
                try {
                    edge.load();
                    var window = new MainWindow (edge.get_name());
                    window.start(edge.get_uri());
                    Gtk.main ();
                }
                catch (GLib.Error err) {
                    print("Failed to load edge: %s\n", err.message);
                }
                break;
            case "delete":
                break;
            default:
                print("Invalid mode\n");
                return 1;
        }
    }
    catch (OptionError err) {
        print("Failed to parse commandline options: %s\n", err.message);
    }

    return 0;
}
