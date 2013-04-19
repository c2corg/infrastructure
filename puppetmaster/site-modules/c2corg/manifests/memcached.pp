class c2corg::memcached {

  package { "php5-memcache":
    ensure => present,
  }

  $session_host = hiera('session_host')

  augeas { 'enable memcache session storage':
    changes => [
      'set Session/session.save_handler memcache',
      "set Session/session.save_path tcp://${session_host}:11211",
    ],
    incl    => '/etc/php5/apache2/php.ini',
    lens    => 'PHP.lns',
    require => Package['php5-memcache'],
    notify  => Service['apache'],
  }
}
