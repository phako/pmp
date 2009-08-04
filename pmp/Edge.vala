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

    public Edge(string name) {
        this.name = name;
        this.file_path = Path.build_filename (
            Environment.get_user_config_dir(),
            Environment.get_prgname(),
            name,
            "edge.conf");
        settings = new KeyFile ();
        debug("Filename: %s", this.file_path);
    }

    public void load() throws Error {
        if (!this.settings.load_from_file (this.file_path,
                                           KeyFileFlags.NONE)) {
            throw new Error.FILE_ERROR("Failed to load edge configuration from file %s", file_path);
        }
    }

    public void set_uri (string uri) {
        settings.set_string("Edge", "uri", uri);
    }

    public string get_uri () {
        return settings.get_string("Edge", "uri");
    }

    public string get_name () { return this.name; }

    public void save() throws GLib.Error {
        var dir = Path.get_dirname (this.file_path);
        debug ("Direcotry: %s", dir);
        if (DirUtils.create_with_parents (dir, 0700) == 0) {
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
}
