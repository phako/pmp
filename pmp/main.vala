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

string mode;
string name;
string uri;
bool create_desktop;

const OptionEntry[] options = {
    { "mode", 'm', 0, OptionArg.STRING, ref mode, "mode to run pmp in (create, run, delete)", "MODE" },
    { "name", 'n', 0, OptionArg.STRING, ref name, "name of edge", "NAME" },
    { null }
};

const OptionEntry[] create_options = {
    { "uri", 'u', 0, OptionArg.STRING, ref uri, "uri of the website to edge", "URI" },
    { "desktop", 'd', 0, OptionArg.NONE, ref create_desktop, "create desktop entry", null },
    { null }
};


int main(string[] args) {
    var opt_ctx = new OptionContext("- Poor man's prism");
    opt_ctx.set_help_enabled (true);
    opt_ctx.add_main_entries (options, null);
    opt_ctx.add_group(Gtk.get_option_group (true));

    OptionGroup option_group = new OptionGroup("create", "Options in create mode",
    "Options for creating edges",
    null, null);
    option_group.add_entries(create_options);
    opt_ctx.add_group((owned)option_group);
    try {
        opt_ctx.parse (ref args);

        switch (mode) {
            case "create":
                break;
            case "run":
                var window = new MainWindow ();
                window.start(name);
                Gtk.main ();
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
