public class WriteAs.MainWindow : Gtk.ApplicationWindow {
    private Gtk.TextView canvas;

    private bool dark_mode = false;
    private string font = "Lora, 'Palatino Linotype',"
            + "'Book Antiqua', 'New York', 'DejaVu serif', serif";

    construct {
        construct_toolbar();

        canvas = new Gtk.TextView();
        add(canvas);

        adjust_text_style();
    }

    public MainWindow(Gtk.Application app) {
        set_application(app);

        set_default_size(800, 600);
    }

    private void construct_toolbar() {
        var header = new Gtk.HeaderBar();
        header.title = "";
        header.show_close_button = true;
        set_titlebar(header);

        var darkmode_button = new Gtk.ToggleButton();
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
        provider.load_from_data("* {font: %s;}".printf(families));
        styles.add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

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
}
