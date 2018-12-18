project('com.github.writeas.writeas-gtk', ['vala', 'c'],
    version: '1.0.1',
    license: 'GPL',
    meson_version: '>=0.40.1')

i18n = import('i18n')
conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

run_target('build', command: 'build-cli.sh')

subdir('data')
subdir('src')
subdir('fonts/lora')

meson.add_install_script('meson/post_install.py')

