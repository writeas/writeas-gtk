executable('write-as-gtk',
    'application.vala',
    'window.vala',

    c_args: ['-include', 'config.h'],
    link_args: '-lm',
    dependencies: [dependency('gtk+-3.0'),
        dependency('libsoup-2.4'),
        dependency('json-glib-1.0')],
    install: true
)
