define xcache::param($value) {

  augeas { "set xcache ${name} param to ${value}":
    changes => "set /files/etc/php5/conf.d/xcache.ini/${name} ${value}",
    require => Package["php5-xcache"],
    notify  => Exec["apache-graceful"],
  }

}
