icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, 'com.abunchtell.WriteAsDesktop.png'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
        rename: '@0@.png'.format(app_id)
    )
endforeach

data_conf = configuration_data()
data_conf.set('app_id', app_id)
data_conf.set('exec', executable)
configure_file(
  input: 'com.abunchtell.WriteAsDesktop.desktop.in',
  output: '@0@.desktop'.format(app_id),
  configuration: data_conf,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

appdata = configure_file(
  input: 'com.abunchtell.WriteAsDesktop.appdata.xml.in',
  output: '@0@.appdata.xml'.format(app_id),
  configuration: data_conf,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test(
    'validate-appdata', appstream_util,
    args: [
     'validate-relax', '--nonet', appdata
    ]
  )
endif
