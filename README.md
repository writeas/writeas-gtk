# Write.as GTK App
A Write.as desktop app that targets all freedesktop.org compliant desktops, e.g. 
GNU/Linux, FreeBSD, etc; basically everything except Windows, Mac, iOS, and 
Android. It allows you to compose and publish posts to https://write.as/.

For a UI toolkit it uses GTK (where some systems may slightly prefer, say, Qt), 
but do to the simplicity of the app this shouldn't be much of a problem to anyone.

## Installation
Write.as GTK uses the [Meson/Ninja](http://mesonbuild.com/) build system, and as such you can install it on
any FreeDesktop.Org compatible system using:

    mkdir build
    cd build
    meson ..
    ninja
    sudo ninja install

This will install the executable file and the metadata required to integrate with
those desktops. It also installs metadata to be collected by package repositories
which integrate with certain package managers for richer presentation of apps.
