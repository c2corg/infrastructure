define xcache::param($value) {

  augeas { "set xcache ${name} param to ${value}":
    incl    => '/etc/php5/conf.d/xcache.ini',
    lens    => 'PHP.lns',
    changes => "set ${name} ${value}",
    require => Package['php5-xcache'],
    notify  => Exec['apache-graceful'],
  }

}
