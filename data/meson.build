icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, meson.project_name() + '.png'),
            install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'
        )
    )
endforeach

install_data('com.github.writeas.writeas-gtk.desktop',
    install_dir: join_paths(get_option('datadir'), 'applications'))
install_data('com.github.writeas.writeas-gtk.appdata.xml',
    install_dir: join_paths(get_option('datadir'), 'metainfo'))
install_data('writeas', install_dir: get_option('bindir'))
