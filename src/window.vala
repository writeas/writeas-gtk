public class WriteAs.MainWindow : Gtk.ApplicationWindow {
    private Gtk.TextView canvas;

    private bool dark_mode = false;

    construct {
        construct_toolbar();

        canvas = new Gtk.TextView();
        add(canvas);
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
    }

    private Gtk.CssProvider cur_styles = null;
    private void adjust_text_style() {
        try {
            var styles = canvas.get_style_context();
            if (cur_styles != null) styles.remove_provider(cur_styles);

            var css = "";
            if (dark_mode) {
                css = "* {background: black; color: white;}";
            }
            cur_styles = new Gtk.CssProvider();
            cur_styles.load_from_data(css);

            styles.add_provider(cur_styles, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (Error e) {
            warning(e.message);
        }
    }
}
