class thttpd {

  package { "thttpd": ensure => present, }
  service { "thttpd":
    ensure  => running,
    enable  => true,
    require => Package["thttpd"],
  }

  etcdefault { 'start thttpd at boot':
    file    => 'thttpd',
    key     => 'ENABLED',
    value   => 'yes',
    before  => Service['thttpd'],
    require => Package['thttpd'],
  }

}
