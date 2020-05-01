project(
    'com.github.writeas.writeas-gtk',
    'vala', 'c',
    version: '1.0.2',
    license: 'GPL-3.0',
)

i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

dependencies = [
    dependency('gtk+-3.0'),
    dependency('gtksourceview-3.0')
]

subdir('src')

executable(
    meson.project_name(),
    sources,
    dependencies: dependencies,
    install: true
)

subdir('data')
subdir('po')

subdir('fonts/lora')

meson.add_install_script('meson/post_install.py')

