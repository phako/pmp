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

using Soup;
using Xml;

public class Pmp.FaviconDownloader : Object {
    private SessionSync session;
    private string uri;
    private File file;

    public FaviconDownloader(string uri) {
        this.uri = uri;
        this.session = new SessionSync();
    }

    public void run(File file) {
        this.file = file;
        var msg = new Message("GET", this.uri);
        session.queue_message ((owned)msg, this.on_download_done);
    }

    private void on_favicon_download_done (Session session, Message message) {
        if (message.status_code == 200) {
            try {
                debug("file: %s", this.file.get_path ());
                file.replace_contents ((string)message.response_body.data,
                                       (size_t)message.response_body.length,
                                       null,
                                       false,
                                       FileCreateFlags.PRIVATE,
                                       null,
                                       null);
                this.done();
            }
            catch (GLib.Error err) {
                this.error();
            }
        }
    }

    private void download_icon (string icon_uri) {
        var msg = new Message ("GET", icon_uri);
        debug ("Trying to download %s", icon_uri);
        session.queue_message ((owned)msg, this.on_favicon_download_done);
    }

    private void on_download_done (Session session, Message message) {
        if (message.status_code == 200) {
            unowned MessageBody body = message.response_body;
            MatchInfo mi;
            Regex fav_re;
            try {
                fav_re = new Regex
                    ("<link\\s+rel\\s*=\\s*\"(shortcut )?icon[^>]+>",
                     RegexCompileFlags.CASELESS);
            } catch (GLib.RegexError e) {
                assert_not_reached ();
            }

            if (fav_re.match ((string)body.data, RegexMatchFlags.NOTBOL, out mi)) {
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
                            var icon_uri = new Soup.URI.with_base (message.uri,
                                attr->children->content);
                            download_icon (icon_uri.to_string(false));
                        }
                    }

                    delete doc;
                }
            }
            else {
                var s = message.uri.to_string(false);
                var t = message.uri.to_string(true);
                string new_uri;
                if (t != "/") {
                    new_uri = s.replace(t, "") + "/favicon.ico";
                }
                else {
                    new_uri = s + "favicon.ico";
                }
                debug("No special favicon link found, trying %s", new_uri);
                download_icon (new_uri);
            }
        }
        else {
            warning("Failed to download site: %s, %s",
                    message.uri.to_string(false),
                    message.reason_phrase);
            error();
        }
    }

    public signal void done();
    public signal void error();
}
