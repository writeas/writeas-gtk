/*
    Copyright © 2018 Write.as

    This file is part of the Write.as GTK desktop app.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
public class WriteAs.MainWindow : Gtk.ApplicationWindow {
    private Gtk.TextView canvas;
    private Gtk.HeaderBar header;
    private Gtk.ToggleButton darkmode_button;

    private static string data_dir = ".writeas";

    private int font_size = 12;
    private bool dark_mode = false;
    private string font = "Lora, 'Palatino Linotype',"
            + "'Book Antiqua', 'New York', 'DejaVu serif', serif";
    private string fontstyle = "serif";
    private bool text_changed = false;

    private bool is_initializing = true;

    construct {
        header = new Gtk.HeaderBar();
        header.title = "Write.as";
        construct_toolbar();
        build_keyboard_shortcuts();

        var scrolled = new Gtk.ScrolledWindow(null, null);
        canvas = new Gtk.TextView();
        canvas.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        scrolled.add(canvas);
        add(scrolled);

        size_allocate.connect((_) => {adjust_text_style();});
        canvas.event_after.connect((evt) => {
            // TODO This word count algorithm may be quite naive
            //      and could do improvement.
            var word_count = canvas.buffer.text.split(" ").length;
            header.subtitle = ngettext("%i word","%i words",word_count).printf(word_count);

            text_changed = true;
        });
        Timeout.add_full(Priority.DEFAULT_IDLE, 100/*ms*/, () => {
            if (!text_changed) return Source.CONTINUE;

            try {
            draft_file().replace_contents(canvas.buffer.text.data, null, false,
                FileCreateFlags.PRIVATE | FileCreateFlags.REPLACE_DESTINATION,
                null);
            text_changed = false;
            } catch (Error err) {/* We'll try again anyways. */}

            return Source.CONTINUE;
        });

        adjust_text_style(false);

    }

    public MainWindow(Gtk.Application app) {
        set_application(app);
        icon_name = "write-as";
        init_folder();
        try {
            open_file(draft_file());
        } catch (Error err) {/* It's fine... */}
        restore_styles();

        set_default_size(800, 600);
        is_initializing = false;
    }

    private static void init_folder() {
        var home = File.new_for_path(get_data_dir());
        try {
            home.make_directory();
        } catch (Error e) {
            stderr.printf("Create data dir: %s\n", e.message);
        }
    }

    private static string get_data_dir() {
        return Environment.get_home_dir() + "/" + data_dir;
    }

    private static File draft_file() {
        var home = File.new_for_path(get_data_dir());
        return home.get_child("draft.txt");
    }

    private void construct_toolbar() {
        header.show_close_button = true;
        set_titlebar(header);

        var publish_button = new Gtk.Button.from_icon_name("document-send",
                Gtk.IconSize.SMALL_TOOLBAR);
        publish_button.clicked.connect(() => {
            canvas.buffer.text += "\n\n" + publish();
        });
        header.pack_end(publish_button);

        darkmode_button = new Gtk.ToggleButton();
        darkmode_button.tooltip_text = _("Toggle dark theme");
        // NOTE the fallback icon is a bit of a meaning stretch, but it works.
        var icon_theme = Gtk.IconTheme.get_default();
        darkmode_button.image = new Gtk.Image.from_icon_name(
                icon_theme.has_icon("writeas-bright-dark") ?
                    "writeas-bright-dark" : "weather-clear-night",
                Gtk.IconSize.SMALL_TOOLBAR);
        darkmode_button.draw_indicator = false;
        var settings = Gtk.Settings.get_default();
        darkmode_button.toggled.connect(() => {
            settings.gtk_application_prefer_dark_theme = darkmode_button.active;
            dark_mode = darkmode_button.active;
            adjust_text_style(!is_initializing);
        });
        header.pack_end(darkmode_button);

        var fonts = new Gtk.MenuButton();
        fonts.tooltip_text = _("Change document font");
        fonts.image = new Gtk.Image.from_icon_name("font-x-generic", Gtk.IconSize.SMALL_TOOLBAR);
        fonts.popup = new Gtk.Menu();
        header.pack_start(fonts);

        build_fontoption(fonts.popup, _("Serif"), "serif", font);
        build_fontoption(fonts.popup, _("Sans-serif"), "sans",
                "'Open Sans', 'Segoe UI', Tahoma, Arial, sans-serif");
        build_fontoption(fonts.popup, _("Monospace"), "wrap", "Hack, consolas," +
                "Menlo-Regular, Menlo, Monaco, 'ubuntu mono', monospace");
        fonts.popup.show_all();
    }

    private unowned SList<Gtk.RadioMenuItem>? font_options = null;
    private void build_fontoption(Gtk.Menu menu,
            string label, string fontstyle, string families) {
        var option = new Gtk.RadioMenuItem.with_label(font_options, label);
        font_options = option.get_group();
        option.activate.connect(() => {
            this.font = families;
            this.fontstyle = fontstyle;
            adjust_text_style(!is_initializing);
        });

        var styles = option.get_style_context();
        var provider = new Gtk.CssProvider();
        try {
            provider.load_from_data("* {font: %s;}".printf(families));
            styles.add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (Error e) {
            warning(e.message);
        }

        menu.add(option);
    }

    private KeyFile theme = new KeyFile();
    private void restore_styles() {
        try {
            loaded_theme = true;

            theme.load_from_file(get_data_dir() + "/prefs.ini", KeyFileFlags.NONE);

            dark_mode = theme.get_boolean("Theme", "darkmode");
            darkmode_button.set_active(dark_mode);
            Gtk.Settings.get_default().gtk_application_prefer_dark_theme = dark_mode;
            font_size = theme.get_integer("Theme", "fontsize");
            font = theme.get_string("Post", "font");
            fontstyle = theme.get_string("Post", "fontstyle");

            adjust_text_style(false);
        } catch (Error err) {/* No biggy... */}
    }

    private Gtk.CssProvider cur_styles = null;
    // So the theme isn't read before it's saved.
    private bool loaded_theme = false;
    private void adjust_text_style(bool save_theme = true) {
        try {
            var styles = canvas.get_style_context();
            if (cur_styles != null)
                Gtk.StyleContext.remove_provider_for_screen(Gdk.Screen.get_default(), cur_styles);

            var padding = canvas.get_allocated_width()*0.10;
            var css = ("GtkTextView {font: %s; font-size: %dpx; padding: 20px;" +
                    " padding-left: %ipx; padding-right: %ipx;" +
                    " -GtkWidget-cursor-color: #5ac4ee;}").printf(font, font_size,
                        (int) padding, (int) padding);
            if (dark_mode) {
                // Try to detect whether the system provided a better dark mode.
                var text_color = styles.get_color(Gtk.StateFlags.ACTIVE);
                double h, s, v;
                Gtk.rgb_to_hsv(text_color.red, text_color.green, text_color.blue,
                        out h, out s, out v);

                if (v < 0.5)
                    css += """GtkTextView {background: black; color: #999;}""";
            }
            cur_styles = new Gtk.CssProvider();
            cur_styles.load_from_data(css);

            Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(),
                    cur_styles, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            if (save_theme && loaded_theme) {
                theme.set_boolean("Theme", "darkmode", dark_mode);
                theme.set_integer("Theme", "fontsize", font_size);
                theme.set_string("Post", "font", font);
                theme.set_string("Post", "fontstyle", fontstyle);

                theme.save_to_file(get_data_dir() + "/prefs.ini");
            }
        } catch (Error e) {
            warning(e.message);
        }
    }

    private string publish() {
        try {
            if (text_changed) {;
            draft_file().replace_contents(canvas.buffer.text.data, null, false,
                FileCreateFlags.PRIVATE | FileCreateFlags.REPLACE_DESTINATION,
                null);
            text_changed = false;
            }

            var cmd = "sh -c 'cat ~/" + data_dir + "/draft.txt | writeas --font %s'";
            cmd = cmd.printf(fontstyle);
            string stdout, stderr;
            int status;
            Process.spawn_command_line_sync(cmd,
                    out stdout, out stderr, out status);

            // Open it in the browser
            if (status == 0) {
                var browser = AppInfo.get_default_for_uri_scheme("https");
                var urls = new List<string>();
                urls.append(stdout.strip());
                browser.launch_uris(urls, null);
            }

            return stderr.strip();
        } catch (Error err) {
            return err.message;
        }
    }
    /* --- */

    private void build_keyboard_shortcuts() {
        /* These operations are not exposed to the UI as buttons,
            as most people are very familiar with them and they are not the
            focus of this app. */
        var accels = new Gtk.AccelGroup();

        // App operations
        accels.connect(Gdk.Key.W, Gdk.ModifierType.CONTROL_MASK,
                Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
                (g,a,k,m) => quit());
        accels.connect(Gdk.Key.Q, Gdk.ModifierType.CONTROL_MASK,
                Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
                (g,a,k,m) => quit());

        // File operations
        accels.connect(Gdk.Key.S, Gdk.ModifierType.CONTROL_MASK,
                Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
                (g,a,k,m) => save_as());
        accels.connect(Gdk.Key.S,
                Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK,
                Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
                (g,a,k,m) => save_as());
        accels.connect(Gdk.Key.O, Gdk.ModifierType.CONTROL_MASK,
                Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED, (g, a, k, m) => {
            try {
                open_file(prompt_file(Gtk.FileChooserAction.OPEN, _("_Open")));
            } catch (Error e) {
                // It's fine...
            }
            return true;
        });

        // Adjust text size
        accels.connect(Gdk.Key.minus, Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED, (g,a,k,m) => {
            if (font_size < 3) {
                return false;
            }
            if (font_size <= 10) {
                font_size -= 1;
            } else {
                font_size -= 2;
            }
            adjust_text_style(true);
            return true;
        });
        accels.connect(Gdk.Key.equal, Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED, (g,a,k,m) => {
            if (font_size < 10) {
                font_size += 1;
            } else {
                font_size += 2;
            }
            adjust_text_style(true);
            return true;
        });

        // Toggle theme with Ctrl+T
        accels.connect(Gdk.Key.T, Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED, (g,a,k,m) => {
            darkmode_button.set_active(!darkmode_button.get_active());
            return true;
        });

        // Publish with Ctrl+Enter
        accels.connect(Gdk.Key.Return, Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED, (g,a,k,m) => {
            canvas.buffer.text += "\n\n" + publish();
            return true;
        });

        add_accel_group(accels);
    }

    private bool save_as() {
        try {
        var file = prompt_file(Gtk.FileChooserAction.SAVE, _("_Save as"));
        file.replace_contents(canvas.buffer.text.data, null, false,
                FileCreateFlags.PRIVATE | FileCreateFlags.REPLACE_DESTINATION,
                null);
        } catch (Error e) {
            // It's fine...
        }
        return true;
    }

    private File prompt_file(Gtk.FileChooserAction mode, string action)
            throws UserCancellable {
        var file_chooser = new Gtk.FileChooserDialog(action, this, mode,
              _("_Cancel"), Gtk.ResponseType.CANCEL,
              action, Gtk.ResponseType.ACCEPT);

        file_chooser.select_multiple = false;
        var filter = new Gtk.FileFilter();
        filter.add_mime_type("text/plain");
        file_chooser.set_filter(filter);

        var resp = file_chooser.run();
        file_chooser.close();
        if (resp == Gtk.ResponseType.ACCEPT) {
            return file_chooser.get_file();
        } else {
            throw new UserCancellable.USER_CANCELLED("FileChooserDialog");
        }
    }

    public void open_file(File file) throws Error {
        uint8[] text;
        file.load_contents(null, out text, null);
        canvas.buffer.text = (string) text;
    }

    private bool quit() {
        this.close();
        return true;
    }
}

errordomain WriteAs.UserCancellable {USER_CANCELLED}
