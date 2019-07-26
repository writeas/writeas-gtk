icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, meson.project_name() + '.png'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
        rename: '@0@.png'.format(app_id)
    )
endforeach

data_conf = configuration_data()
data_conf.set('app_id', app_id)
configure_file(
  input: 'writeas-gtk.desktop.in',
  output: '@0@.desktop'.format(app_id),
  configuration: data_conf,
  install_dir: join_paths(get_option('datadir'), 'applications')
)
configure_file(
  input: 'writeas-gtk.appdata.xml.in',
  output: '@0@.appdata.xml'.format(app_id),
  configuration: data_conf,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)
