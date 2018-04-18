public class WriteAs.MainWindow : Gtk.ApplicationWindow {
    private Gtk.TextView canvas;

    private bool dark_mode = false;
    private string font = "Lora, 'Palatino Linotype',"
            + "'Book Antiqua', 'New York', 'DejaVu serif', serif";
    private string fontstyle = "serif";

    construct {
        construct_toolbar();
        build_keyboard_shortcuts();

        var scrolled = new Gtk.ScrolledWindow(null, null);
        canvas = new Gtk.TextView();
        canvas.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        scrolled.add(canvas);
        add(scrolled);

        var text_changed = false;
        canvas.event_after.connect((evt) => {
            // TODO This word count algorithm may be quite naive
            //      and could do improvement.
            var word_count = canvas.buffer.text.split(" ").length;
            title = ngettext("%i word","%i words",word_count).printf(word_count);

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

        adjust_text_style();
    }

    public MainWindow(Gtk.Application app) {
        set_application(app);
        try {
            open_file(draft_file());
        } catch (Error err) {/* It's fine... */}

        set_default_size(800, 600);
    }

    private static File draft_file() {
        var home = File.new_for_path(Environment.get_home_dir());
        return home.get_child(".writeas-draft.txt");
    }

    private void construct_toolbar() {
        var header = new Gtk.HeaderBar();
        header.show_close_button = true;
        set_titlebar(header);

        var publish_button = new Gtk.Button.from_icon_name("document-send",
                Gtk.IconSize.SMALL_TOOLBAR);
        publish_button.clicked.connect(() => {
            title = _("Publishing post…");
            canvas.sensitive = false;
            publish.begin((obj, res) => {
                canvas.buffer.text += "\n\n" + publish.end(res);
                canvas.sensitive = true;
            });
        });
        header.pack_end(publish_button);

        var darkmode_button = new Gtk.ToggleButton();
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
            adjust_text_style();
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

    private void build_fontoption(Gtk.Menu menu,
            string label, string fontstyle, string families) {
        var option = new Gtk.MenuItem.with_label(label);
        option.activate.connect(() => {
            this.font = families;
            this.fontstyle = fontstyle;
            adjust_text_style();
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

    private Gtk.CssProvider cur_styles = null;
    private void adjust_text_style() {
        try {
            var styles = canvas.get_style_context();
            if (cur_styles != null) styles.remove_provider(cur_styles);

            var css = "* {font: %s; padding: 20px;}".printf(font);
            if (dark_mode) {
                // Try to detect whether the system provided a better dark mode.
                var text_color = styles.get_color(Gtk.StateFlags.ACTIVE);
                double h, s, v;
                Gtk.rgb_to_hsv(text_color.red, text_color.green, text_color.blue,
                        out h, out s, out v);

                if (v < 0.5) css += "* {background: black; color: white;}";
            }
            cur_styles = new Gtk.CssProvider();
            cur_styles.load_from_data(css);

            styles.add_provider(cur_styles, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (Error e) {
            warning(e.message);
        }
    }

    private async string publish() {
        var session = new Soup.Session();

        // Send the request
        var req = new Soup.Message("POST", "https://write.as/api/posts");
        // TODO specify font.
        var req_body = "{\"body\": \"%s\", \"font\": \"%s\"}".printf(
                canvas.buffer.text, fontstyle);
        req.set_request("application/json", Soup.MemoryUse.COPY, req_body.data);
        try {
            var resp = yield session.send_async(req);

            // Handle the response
            if (req.status_code != 201)
                return _("Error code: HTTP %u").printf(req.status_code);
            var json = new Json.Parser();
            json.load_from_stream(resp);
            var data = json.get_root().get_object().get_object_member("data");
            var url = "https://write.as/" + data.get_string_member("id");

            Gtk.Clipboard.get_default(get_display()).set_text(url, -1);

            // Open it in the browser
            var browser = AppInfo.get_default_for_uri_scheme("https");
            var urls = new List<string>();
            urls.append(url);
            browser.launch_uris(urls, null);

            return _("The link to your published article has been copied into your clipboard for you.");
        } catch (Error err) {
            return _("Failed to upload post! Are you connected to the Internet?")
                    + "\n\n" + err.message;
        }
    }
    /* --- */

    private void build_keyboard_shortcuts() {
        /* These operations are not exposed to the UI as buttons,
            as most people are very familiar with them and they are not the
            focus of this app. */
        var accels = new Gtk.AccelGroup();

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
        if (resp == Gtk.ResponseType.ACCEPT) return file_chooser.get_file();
        else throw new UserCancellable.USER_CANCELLED("FileChooserDialog");
    }

    public void open_file(File file) throws Error {
        uint8[] text;
        file.load_contents(null, out text, null);
        canvas.buffer.text = (string) text;
    }
}

errordomain WriteAs.UserCancellable {USER_CANCELLED}
