project('writeas-gtk', ['vala', 'c'],
    version: '0.1',
    license: 'GNU',
    meson_version: '>=0.40.1')

i18n = import('i18n')
conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

subdir('data')
subdir('src')
