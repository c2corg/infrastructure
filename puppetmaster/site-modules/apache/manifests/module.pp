define apache::module ($ensure='present') {

  include apache::params

  case $ensure {
    'present' : {
      exec { "a2enmod ${name}":
        command => "/usr/sbin/a2enmod ${name}",
        unless  => "/bin/sh -c '[ -L ${apache::params::conf}/mods-enabled/${name}.load ] \\
          && [ ${apache::params::conf}/mods-enabled/${name}.load -ef ${apache::params::conf}/mods-available/${name}.load ]'",
        require => Package['apache'],
        notify  => Service['apache'],
      }
    }

    'absent': {
      exec { "a2dismod ${name}":
        command => "/usr/sbin/a2dismod ${name}",
        onlyif  => "/bin/sh -c '[ -L ${apache::params::conf}/mods-enabled/${name}.load ] \\
          || [ -e ${apache::params::conf}/mods-enabled/${name}.load ]'",
        require => Package['apache'],
        notify  => Service['apache'],
      }
    }

    default: {
      fail ( "Unknown ensure value: '${ensure}'" )
    }
  }
}
