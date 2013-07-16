define nginx::site ($ensure=present, $source=undef, $content=undef) {

  file { "/etc/nginx/sites-available/${name}.conf":
    ensure  => $ensure,
    source  => $source,
    content => $content,
    require => Package['nginx'],
    notify  => Exec['reload-nginx'],
  } ->

  file { "/etc/nginx/sites-enabled/${name}.conf":
    ensure => $ensure ? {
      'present' => link,
      'absent'  => absent,
    },
    target => "../sites-available/${name}.conf",
    notify => Exec['reload-nginx'],
  }

}
