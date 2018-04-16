public class WriteAs.Application : Gtk.Application {
    construct {
        Intl.setlocale(LocaleCategory.ALL, "");
        Intl.textdomain("write.as");

        application_id = "write-as-gtk.desktop";
    }

    public override void activate() {
        if (get_windows().length() == 0)
            new Gtk.ApplicationWindow(this).show_all();
    }

    public static int main(string[] args) {
        return new WriteAs.Application().run(args);
    }
}
