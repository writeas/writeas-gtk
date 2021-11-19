# Project name, programming language and version
project (
    'com.github.writeas.writeas-gtk',
    'c', 'vala',
    version: '1.0.2',
)


# GNOME module
gnome = import ('gnome')

# Translation module
i18n = import ('i18n')


# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    language: 'c'
)

# Listing dependencies
dependencies = [
    dependency ('gtk+-3.0'),
    dependency ('gtksourceview-3.0')
]

run_target('build', command: 'meson/build-cli.sh')

subdir ('src')

# Define executable
executable (
    meson.project_name (),
    sources,
    dependencies: dependencies,
    install: true
)

subdir ('data')
subdir ('po')

subdir ('fonts/lora')

meson.add_install_script ('meson/post_install.py')
