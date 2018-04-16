public class WriteAs.MainWindow : Gtk.ApplicationWindow {
    private Gtk.TextView canvas;

    construct {
        var header = new Gtk.HeaderBar();
        header.title = "";
        header.show_close_button = true;
        set_titlebar(header);

        canvas = new Gtk.TextView();
        add(canvas);
    }

    public MainWindow(Gtk.Application app) {
        set_application(app);
    }
}
