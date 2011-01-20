class haproxy {

  package { "haproxy":
    ensure => present
  }

  service { "haproxy":
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => "/etc/init.d/haproxy reload",
    require   => Package["haproxy"],
  }

  augeas { "enable haproxy" :
    context => "/files/etc/default/haproxy",
    changes => "set ENABLED 1",
    notify  => Service["haproxy"],
  }

  file { "/etc/haproxy/haproxy.cfg":
    ensure => present,
    owner  => "root",
    mode   => 0644,
    source => "puppet:///c2corg/ha/haproxy.cfg",
    notify => Service["haproxy"],
  }

  #TODO: collectd

}
