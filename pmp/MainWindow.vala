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
using WebKit;

public class Pmp.MainWindow : Window {
    private WebView web_view;

    public MainWindow() {
        this.title = "PMP - Poor man's Prism";
        set_default_size (1024, 768);

        this.web_view = new WebView();
        this.add (web_view);

        this.destroy.connect(Gtk.main_quit);
        show_all();
    }

    public void start(string url) {
        this.web_view.open (url);
    }
}
