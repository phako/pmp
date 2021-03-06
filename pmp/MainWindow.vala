/*
 * Copyright (C) 2009,2010 Jens Georg <mail@jensge.org>
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
    private Statusbar statusbar;
    private uint context_id;
    private Regex local_regex;

    public MainWindow (string title) {
        this.title = "PMP - Poor man's Prism: %s".printf (title);
        set_default_size (1024, 768);
        var vbox = new VBox (false, 5);

        this.local_regex = new Regex ("([^.]+)\\.([^.]+)$");

        this.web_view = new WebView ();
        this.add (vbox);
        this.statusbar = new Statusbar ();
        this.statusbar.has_resize_grip = false;
        this.context_id = this.statusbar.get_context_id ("pmp_progress");
        this.web_view.load_progress_changed.connect (on_load_progress);
        this.web_view.new_window_policy_decision_requested.connect (on_policy_decision_requested);
        this.web_view.navigation_policy_decision_requested.connect (on_nav_policy_decision_req);
        this.web_view.mime_type_policy_decision_requested.connect (on_mime_policy_descision_req);
        this.web_view.download_requested.connect (on_download);

        vbox.pack_start (web_view, true, true, 0);
        vbox.pack_end (this.statusbar, false, false, 0);

        this.destroy.connect (Gtk.main_quit);
        show_all ();
    }

    public void on_load_progress (int p0) {
        this.statusbar.push (this.context_id, "%3d%%".printf(p0));
    }

    public bool on_download (GLib.Object _download) {
        bool retval = false;
        var download = (Download) _download;
        var dialog = new FileChooserDialog ("Download file...",
                                            this,
                                            FileChooserAction.SAVE,
                                            STOCK_CANCEL,
                                            ResponseType.REJECT,
                                            STOCK_SAVE,
                                            ResponseType.ACCEPT);

        dialog.set_current_name (download.get_suggested_filename ());
        var res = dialog.run ();
        dialog.hide ();
        switch (res) {
            case ResponseType.ACCEPT:
                download.set_destination_uri (dialog.get_uri ());
                retval = true;

                break;
        }

        dialog.destroy ();

        return retval;
    }

    public bool on_mime_policy_descision_req(WebView           web_view,
                                             WebFrame          frame,
                                             NetworkRequest    request,
                                             string            mimetype,
                                             WebPolicyDecision policy_decision) {
        if (web_view.can_show_mime_type (mimetype)) {
            policy_decision.use ();
        }
        else {
            policy_decision.download ();
        }

        return true;
    }


    public bool on_policy_decision_requested (WebFrame frame,
                                              NetworkRequest request,
                                              WebNavigationAction action,
                                              WebPolicyDecision decision) {
        // we don't handle links leaving us in here. Just handle them like a
        // normal application and call the browser
        decision.ignore ();

        try {
            Gtk.show_uri (null, request.get_uri(), Gdk.CURRENT_TIME);
        }
        catch (GLib.Error err) {
            warning("Failed to launch external browser for %s: %s",
                    request.get_uri (),
                    err.message);
        }

        return true;
    }

    public bool on_nav_policy_decision_req (WebFrame frame,
                                            NetworkRequest request,
                                            WebNavigationAction action,
                                            WebPolicyDecision decision) {
        MatchInfo frame_match;
        string canonical_frame_host = null;
        string canonical_request_host = null;

        if (frame.get_uri () == null ||
            request.get_message () == null) {
            return false;
        }

        var frame_host = new Soup.URI (frame.get_uri ()).host;
        var request_host = request.get_message ().get_uri ().host;

        if (frame_host != null) {
            if (this.local_regex.match (frame_host, 0, out frame_match)) {
                canonical_frame_host = frame_match.fetch (1);
            }

            if (this.local_regex.match (request_host, 0, out frame_match)) {
                canonical_request_host = frame_match.fetch (1);
            }
        }

        debug ("canonical_frame_host: %s => canonical_request_host: %s",
                canonical_frame_host, canonical_request_host);

        // check if this link will leave the domain
        if (canonical_frame_host != null && 
            canonical_frame_host != canonical_request_host) {

            return on_policy_decision_requested (frame,
                                                 request,
                                                 action,
                                                 decision);
        }

        return false;
    }


    public void start (string url) {
        this.web_view.open (url);
    }
}
