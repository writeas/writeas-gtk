// From https://github.com/elementary/granite/blob/621f2669f6c8940fe32ac9817ddca92e97d27ae0/lib/Widgets/Utils.vala#L79-L192

/*
 *  Copyright (C) 2012-2017 Granite Developers
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 */

namespace Granite {

/**
 * Converts a {@link Gtk.accelerator_parse} style accel string to a human-readable string.
 *
 * @param accel an accelerator label like “<Control>a” or “<Super>Right”
 *
 * @return a human-readable string like "Ctrl + A" or "⌘ + →"
 */
public static string accel_to_string (string accel) {
    uint accel_key;
    Gdk.ModifierType accel_mods;
    Gtk.accelerator_parse (accel, out accel_key, out accel_mods);

    string[] arr = {};
    if (Gdk.ModifierType.SUPER_MASK in accel_mods) {
        arr += "⌘";
    }

    if (Gdk.ModifierType.SHIFT_MASK in accel_mods) {
        arr += _("Shift");
    }

    if (Gdk.ModifierType.CONTROL_MASK in accel_mods) {
        arr += _("Ctrl");
    }

    if (Gdk.ModifierType.MOD1_MASK in accel_mods) {
        arr += _("Alt");
    }

    switch (accel_key) {
        case Gdk.Key.Up:
            arr += "↑";
            break;
        case Gdk.Key.Down:
            arr += "↓";
            break;
        case Gdk.Key.Left:
            arr += "←";
            break;
        case Gdk.Key.Right:
            arr += "→";
            break;
        case Gdk.Key.minus:
        case Gdk.Key.KP_Subtract:
            // TRANSLATORS: This is a non-symbol representation of the "-" key
            arr += _("Minus");
            break;
        case Gdk.Key.KP_Add:
        case Gdk.Key.plus:
            // TRANSLATORS: This is a non-symbol representation of the "+" key
            arr += _("Plus");
            break;
        case Gdk.Key.KP_Enter:
        case Gdk.Key.Return:
            arr += _("Enter");
            break;
        default:
            arr += Gtk.accelerator_get_label (accel_key, 0);
            break;
    }

    return string.joinv (" + ", arr);
}

/**
 * Takes a description and an array of accels and returns {@link Pango} markup for use in a {@link Gtk.Tooltip}. This method uses {@link Granite.accel_to_string}.
 *
 * Example:
 *
 * Description
 * Shortcut 1, Shortcut 2
 *
 * @param a string array of accelerator labels like {"<Control>a", "<Super>Right"}
 *
 * @param description a standard tooltip text string
 *
 * @return {@link Pango} markup with the description label on one line and a list of human-readable accels on a new line
 */
public static string markup_accel_tooltip (string[]? accels, string? description = null) {
    string[] parts = {};
    if (description != null && description != "") {
        parts += description;
    }

    if (accels != null &&  accels.length > 0) {
        string[] unique_accels = {};

        for (int i = 0; i < accels.length; i++) {
            if (accels[i] == "") {
                continue;
            }

            var accel_string = accel_to_string (accels[i]);
            if (!(accel_string in unique_accels)) {
                unique_accels += accel_string;
            }
        }

        if (unique_accels.length > 0) {
            // TRANSLATORS: This is a delimiter that separates two keyboard shortcut labels like "⌘ + →, Control + A"
            var accel_label = string.joinv (_(", "), unique_accels);

            var accel_markup = """<span weight="600" size="smaller" alpha="75%">%s</span>""".printf (accel_label);

            parts += accel_markup;
        }
    }

    return string.joinv ("\n", parts);
}

}

