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
public class WriteAs.Application : Gtk.Application {
    construct {
        this.flags |= ApplicationFlags.HANDLES_OPEN;
        Intl.setlocale(LocaleCategory.ALL, "");
        Intl.textdomain("write.as");

        application_id = "writeas-gtk.desktop";
    }

    public override void activate() {
        if (get_windows().length() == 0)
            new WriteAs.MainWindow(this).show_all();
    }

    public override void open(File[] files, string hint) {
        activate(); // ensure we have a window open.
    }

    public static int main(string[] args) {
        return new WriteAs.Application().run(args);
    }
}
