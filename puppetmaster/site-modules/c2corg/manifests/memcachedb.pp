class c2corg::memcachedb {

  package { "php5-memcache":
    ensure => present,
  }

  augeas { "enable memcache session storage":
    context => "/files/etc/php5/apache2/php.ini/Session/",
    changes => [
      "set session.save_handler memcache",
      "set session.save_path tcp://${session_host}:11211",
    ],
    require => Package["php5-memcache"],
    notify  => Service["apache"],
  }
}
