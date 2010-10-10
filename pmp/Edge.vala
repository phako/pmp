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

public errordomain Pmp.Error {
    FILE_ERROR
}

public class Pmp.Edge : Object {
    private string name;
    private string file_path;
    private KeyFile settings;
    private string edge_path;

    private static string edge_directory;

    public static string get_edge_directory () {
        if (Edge.edge_directory == null) {
            Edge.edge_directory = Path.build_filename (
                                        Environment.get_user_config_dir(),
                                        "pmp");
        }

        return Edge.edge_directory;
    }

    public Edge(string name) {
        this.name = name;
        this.edge_path = Path.build_filename (get_edge_directory (),
                                              name);
        this.file_path = Path.build_filename (this.edge_path,
                                              "edge.conf");
        settings = new KeyFile ();
        debug("Filename: %s", this.file_path);
    }

    public void load() throws GLib.Error {
        if (!this.settings.load_from_file (this.file_path,
                                           KeyFileFlags.NONE)) {
            throw new Error.FILE_ERROR("Failed to load edge configuration from file %s", file_path);
        }
    }

    public void set_uri (string uri) {
        settings.set_string("Edge", "uri", uri);
    }

    public string get_uri () throws GLib.Error {
        return settings.get_string("Edge", "uri");
    }

    public string get_name () { return this.name; }

    public void save() throws GLib.Error {
        if (DirUtils.create_with_parents (this.edge_path, 0700) == 0) {
            var file = File.new_for_commandline_arg (this.file_path);
            var contents = this.settings.to_data();
            file.replace_contents (contents,
                    contents.length,
                    null,
                    false,
                    FileCreateFlags.PRIVATE,
                    null,
                    null);
        }
        else {
            warning ("Failed to create drectory");
        }
    }

    public File get_default_icon_file() {
        return File.new_for_commandline_arg (Path.build_filename (
                                             this.edge_path,
                                             "favicon.ico"));
    }

    public void set_use_default_icon() {
        settings.set_string("Edge", "icon",
                get_default_icon_file().get_path());
    }

    public string get_icon() {
        return settings.get_string("Edge", "icon");
    }
}
