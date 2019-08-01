if build_platform == 'elementary'
  executable = 'com.github.writeas.writeas-gtk'
else
  executable = 'writeas-gtk'
endif

if get_option('auto_build_cli')
  gb = find_program('gb')

  cli_target = custom_target('build-cli',
      build_by_default: true,
      output: 'writeas',
      install: true,
      install_dir: get_option('bindir'),
      console: true,
      command: [
        cli_build_script,
        '@SOURCE_ROOT@',
        '@OUTPUT@',
        meson.build_root()
      ]
  )
endif

executable(executable,
    'application.vala',
    'window.vala',
    'Granite/Accels.vala',
    'Granite/ModeSwitch.vala',

    c_args: ['-include', 'config.h'],
    link_args: '-lm',
    dependencies: [dependency('gtk+-3.0'), dependency('gtksourceview-3.0')],
    install: true
)
