# Write.as GTK App
A Write.as desktop app that targets all freedesktop.org compliant desktops, e.g. 
GNU/Linux, FreeBSD, etc; basically everything except Windows, Mac, iOS, and 
Android. It lets you compose and publish posts to [Write.as](https://write.as/).

For a UI toolkit it uses GTK, and relies on the [writeas-cli](https://github.com/writeas/writeas-cli) for API calls and post management.

## Installation
Write.as GTK uses the [Meson/Ninja](http://mesonbuild.com/) build system, and as such you can install it on
any FreeDesktop.Org compatible system using:

    meson build && cd build
    ninja
    sudo ninja install

This will install the executable file and the metadata required to integrate with
those desktops. It also installs metadata to be collected by package repositories
which integrate with certain package managers for richer presentation of apps.

## Packaging
You can package Write.as GTK for Debian/Apt-based systems by running in this
repository's root directory:

    dpkg-buildpackage -us -uc

This'll give you a .deb file in the parent directory.
