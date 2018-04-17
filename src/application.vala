public class WriteAs.Application : Gtk.Application {
    construct {
        this.flags |= ApplicationFlags.HANDLES_OPEN;
        Intl.setlocale(LocaleCategory.ALL, "");
        Intl.textdomain("write.as");

        application_id = "write-as-gtk.desktop";
    }

    public override void activate() {
        if (get_windows().length() == 0)
            new WriteAs.MainWindow(this).show_all();
    }

    public override void open(File[] files, string hint) {
        activate(); // ensure we have a window open.
        try {
            (get_windows().data as MainWindow).open_file(files[0]);
        } catch (Error e) {
            error(e.message);
        }
    }

    public static int main(string[] args) {
        return new WriteAs.Application().run(args);
    }
}
