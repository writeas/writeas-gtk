public class WriteAs.MainWindow : Gtk.ApplicationWindow {
    private Gtk.TextView canvas;

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
        });
        header.pack_end(darkmode_button);
    }
}
