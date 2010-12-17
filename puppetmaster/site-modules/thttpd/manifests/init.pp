class thttpd {

  package { "thttpd": ensure => present, }
  service { "thttpd":
    ensure  => running,
    enable  => true,
    require => Package["thttpd"],
  }

  augeas { "enable thttpd service":
    changes => "set /files/etc/default/thttpd/ENABLED yes",
    before  => Service["thttpd"],
    require => Package["thttpd"],
  }

}
