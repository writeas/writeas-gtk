executable('com.github.writeas.writeas-gtk',
    'application.vala',
    'window.vala',
    'Widgets/ModeSwitch.vala',

    c_args: ['-include', 'config.h'],
    link_args: '-lm',
    dependencies: [dependency('gtk+-3.0'), dependency('gtksourceview-3.0')],
    install: true
)
