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


public class Pmp.EdgeCreator : Object {
    private static string name;
    private static string uri;
    private static bool create_desktop;
    private static string icon_file;
    private MainLoop loop;
    private Edge edge;

    const OptionEntry[] options = {
        { "name", 'n', 0, OptionArg.STRING, ref name, "name of edge", "NAME" },
        { "url", 'u', 0, OptionArg.STRING, ref uri, "uri of the website to edge", "URI" },
        { "desktop", 'd', 0, OptionArg.NONE, ref create_desktop, "create desktop entry", null },
        { "icon", 'i', 0, OptionArg.FILENAME, ref icon_file, "use ICON as icon (use :favicon for the site's favicon", "ICON" },
        { null }
    };

    private void on_fileicon_done() {
        edge.set_use_default_icon();
        edge.save();
        loop.quit();
    }

    private void on_fileicon_error() {
        loop.quit();
    }

    public void run(string[] args) {
        var opt_ctx = new OptionContext("- Poor man's prism");
        opt_ctx.set_help_enabled (true);
        opt_ctx.add_main_entries (options, null);
        try {
            opt_ctx.parse (ref args);
            if (name != null) {
                if (uri != null) {
                    edge = new Edge(name);
                    edge.set_uri (uri);
                    edge.save();
                    if (icon_file != null) {
                        if (icon_file == ":favicon") {
                            var dld = new FaviconDownloader (uri);
                            var file = edge.get_default_icon_file();
                            dld.done.connect(on_fileicon_done);
                            dld.error.connect(on_fileicon_error);
                            dld.run(file);
                            loop = new MainLoop (null, false);
                            loop.run();
                            icon_file = file.get_path ();
                        }
                    }
                    if (create_desktop) {
                        var desktop_dir = Environment.get_user_special_dir (UserDirectory.DESKTOP);
                        var desktop_file = new KeyFile();
                        desktop_file.set_string("Desktop Entry",
                                                "Name",
                                                name);
                        desktop_file.set_string("Desktop Entry",
                                                "Type",
                                                "Application");
                        desktop_file.set_string("Desktop Entry",
                                                "Comment",
                                                "Web Application");
                        desktop_file.set_string("Desktop Entry",
                                                "Exec",
                                                "pmp-run --name=\"%s\"".printf(name));
                        if (icon_file != null) {
                            desktop_file.set_string("Desktop Entry",
                                                    "Icon",
                                                    icon_file);
                        }
                        var f = File.new_for_commandline_arg
                            (Path.build_filename (desktop_dir,
                                                  "%s.desktop".printf(name)));
                        size_t len;
                        string data = desktop_file.to_data(out len);
                        f.replace_contents (data,
                                len,
                                null,
                                false,
                                FileCreateFlags.PRIVATE,
                                null,
                                null);
                    }
                }
                else {
                    print("Missing option: --url\n");
                }
            }
        }
        catch (OptionError err) {
            print("Invalid options: %s\n", err.message);
        }
    }
}

int main(string[] args) {
    var creator = new Pmp.EdgeCreator();
    creator.run (args);

    return 0;
}
