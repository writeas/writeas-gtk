# Write.as GTK App

[![Get the app from Write.as](https://write.as/img/downloadwriteas.png)](https://write.as/apps/desktop) &nbsp;
[![Get the app on AppCenter](https://write.as/img/appcenter.png)](https://appcenter.elementary.io/com.github.writeas.writeas-gtk)

A Write.as desktop app that targets all freedesktop.org compliant desktops, e.g. 
GNU/Linux, FreeBSD, etc; basically everything except Windows, Mac, iOS, and 
Android. It lets you compose and publish posts to [Write.as](https://write.as/).

For a UI toolkit it uses GTK, and relies on the [writeas-cli](https://github.com/writeas/writeas-cli) for API calls and post management.

---

**This is a fork of the [writeas-gtk application](https://code.as/writeas/writeas-gtk), containing necessary changes to release the app for elementaryOS.** 

This repo shouldn't be used by other package maintainers. Version 1.0.x numbers are out of sync with the [official releases](https://code.as/writeas/writeas-gtk/releases) while we try to get the app submitted to AppCenter (see [#5](https://github.com/writeas/writeas-gtk/issues/5)).

## Usage

See the [User Guide](https://code.as/writeas/writeas-gtk/src/branch/master/USER_GUIDE.md).

## Installation
Write.as GTK uses the [Meson/Ninja](http://mesonbuild.com/) build system, and as such you can install it on
any FreeDesktop.Org compatible system using:

```bash
# Install latest version of meson
# Either via pip:
pip3 install meson
# Or, if you need to build the .deb:
sudo add-apt-repository ppa:jonathonf/meson
sudo apt update
sudo apt install meson

# Build
meson build && cd build
ninja

# Install
sudo ninja install
```

This will install the executable file and the metadata required to integrate with
those desktops. It also installs metadata to be collected by package repositories
which integrate with certain package managers for richer presentation of apps.

Though not required for local use, Write.as GTK relies on our [command-line interface](https://github.com/writeas/writeas-cli) for publishing to Write.as.
Install it by downloading the [latest release](https://github.com/writeas/writeas-cli/releases/latest) or, with [Go (golang)](https://golang.org) installed, running:

```bash
go get github.com/writeas/writeas-cli/cmd/writeas
```

## Packaging
You can package Write.as GTK for Debian/Apt-based systems by running in this
repository's root directory:

    dpkg-buildpackage -us -uc

This'll give you a .deb file in the parent directory.
