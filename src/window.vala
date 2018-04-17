public class WriteAs.MainWindow : Gtk.ApplicationWindow {
    private Gtk.TextView canvas;

    private bool dark_mode = false;
    private string font = "Lora, 'Palatino Linotype',"
            + "'Book Antiqua', 'New York', 'DejaVu serif', serif";

    construct {
        construct_toolbar();
        build_keyboard_shortcuts();

        canvas = new Gtk.TextView();
        add(canvas);
        canvas.event_after.connect((evt) => {
            // TODO This word count algorithm may be quite naive
            //      and could do improvement.
            var word_count = canvas.buffer.text.split(" ").length;
            title = ngettext("%i word","%i words",word_count).printf(word_count);
        });

        adjust_text_style();
    }

    public MainWindow(Gtk.Application app) {
        set_application(app);

        set_default_size(800, 600);
    }

    private void construct_toolbar() {
        var header = new Gtk.HeaderBar();
        header.show_close_button = true;
        set_titlebar(header);

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

        build_fontoption(fonts.popup, _("Serif"), font);
        build_fontoption(fonts.popup, _("Sans-serif"), "'Open Sans', 'Segoe UI',"
                + "Tahoma, Arial, sans-serif");
        build_fontoption(fonts.popup, _("Monospace"), "Hack, consolas," +
                "Menlo-Regular, Menlo, Monaco, 'ubuntu mono', monospace");
        fonts.popup.show_all();
    }

    private void build_fontoption(Gtk.Menu menu, string label, string families) {
        var option = new Gtk.MenuItem.with_label(label);
        option.activate.connect(() => {
            this.font = families;
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

    private async void publish() throws Error {
        // Could use libsoup, but I'll exercise the commandline interface.
        // Mostly because it already has Tor integration.
        IOChannel stdin, stdout, stderr;
        yield spawn_commandline_with_pipes({"writeas"},
                out stdin, out stdout, out stderr);

        while (stdin.write_chars((char[]) canvas.buffer.text.data, null)
                != IOStatus.AGAIN) {}
        if (stdin.shutdown(true) != IOStatus.NORMAL)
            throw new PublishError.IO(_("Unknown IO Error!"));

        string errmsg;
        stderr.read_to_end(out errmsg, null);
        errmsg = errmsg.strip();
        info("Errors were: %s", errmsg);
        if (errmsg == "" ||
                // This error is fine, we'll show the browser anyways.
                errmsg.has_prefix("writeas: Didn't copy to clipboard")) {
            throw new PublishError.UPSTREAM(errmsg);
        }

        string url;
        stdout.read_to_end(out url, null);
        url = url.strip();
        var browser = AppInfo.get_default_for_uri_scheme("https");
        var uris = new List<string>();
        uris.append(url);
        browser.launch_uris(uris, null);
    }

    private static async void spawn_commandline_with_pipes(string[] cmd,
            out IOChannel stdin = null, out IOChannel stdout = null,
            out IOChannel stderr = null, out int pid = null) throws Error {
        int stdin_id, stdout_id, stderr_id;
        Process.spawn_async_with_pipes(null, cmd, null,
                SpawnFlags.SEARCH_PATH, null, out pid,
                out stdin_id, out stdout_id, out stderr_id);
        stdin = new IOChannel.unix_new(stdin_id);
        stdout = new IOChannel.unix_new(stdout_id);
        stderr = new IOChannel.unix_new(stderr_id);
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
errordomain WriteAs.PublishError {IO, UPSTREAM}
