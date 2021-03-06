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
using Gdk;
using Pmp;

string name;
bool list;

const OptionEntry[] options = {
    { "name", 'n', 0, OptionArg.STRING, ref name, "name of edge", "NAME" },
    { "list", 'l', 0, OptionArg.NONE, ref list, "list available edges", null },
    { null }
};

void run_edge () {
    var edge = new Edge(name);
    try {
        edge.load();
        var window = new MainWindow (edge.get_name());
        var icon = edge.get_icon ();
        if (icon != null) {
            var icon_list = new List<Pixbuf>();
            icon_list.append(new Pixbuf.from_file (icon));
            window.set_icon_list (icon_list);
        }
        window.start(edge.get_uri());
        Gtk.main ();
    }
    catch (GLib.Error err) {
        print("Failed to load edge: %s\n", err.message);
    }
}

void show_edges () throws GLib.Error {
    var dir = File.new_for_path (Edge.get_edge_directory ());
    var enumerator = dir.enumerate_children (FILE_ATTRIBUTE_STANDARD_NAME,
                                             FileQueryInfoFlags.NONE);
    var info = enumerator.next_file ();
    while (info != null) {
        try {
            var edge = new Edge (info.get_name ());
            edge.load ();

            print ("Edge %s pointing to %s\n",
                    edge.get_name (),
                    edge.get_uri ());
        }
        catch (GLib.Error error) {
            // ignore
        }
        info = enumerator.next_file ();
    }
}

int main(string[] args) {
    var opt_ctx = new OptionContext("- Poor man's prism");
    opt_ctx.set_help_enabled (true);
    opt_ctx.add_main_entries (options, null);
    opt_ctx.add_group(Gtk.get_option_group (true));

    try {
        opt_ctx.parse (ref args);

        if (list) {
            show_edges ();
            return 0;
        }

        if (name != null) {
            run_edge ();
        }
    }
    catch (OptionError err) {
        print("Failed to parse commandline options: %s\n", err.message);
    }

    return 0;
}
