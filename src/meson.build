executable(app_id,
    'application.vala',
    'window.vala',
    'Granite/Accels.vala',
    'Granite/ModeSwitch.vala',

    c_args: ['-include', 'config.h'],
    link_args: '-lm',
    dependencies: [dependency('gtk+-3.0'), dependency('gtksourceview-3.0')],
    install: true
)
