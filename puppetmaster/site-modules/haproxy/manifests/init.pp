class haproxy {

  package { "haproxy":
    ensure => present,
    before => File["/etc/haproxy/haproxy.cfg"],
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

}

class haproxy::collectd {

  include haproxy::collectd::typesdb

  $plugin= "/usr/local/sbin/haproxy-stat.sh"

  package { "socat": }

  file { "haproxy collectd plugin":
    path    => $plugin,
    source  => "puppet:///haproxy/haproxy-stat.sh",
    mode    => 0755,
    require => Package["socat"],
    notify  => Service["collectd"],
  }

  collectd::plugin { "haproxy":
    content => "# file managed by puppet
Loadplugin \"exec\"
<Plugin exec>
  Exec \"haproxy:haproxy\" \"${plugin}\"
</Plugin>
",
    require => [
      File["haproxy collectd plugin"],
      File["haproxy collectd types"],
      Service["haproxy"],
    ],
  }

}

class haproxy::collectd::typesdb {

  $typesdb = "/usr/share/collectd/haproxy.db"

  collectd::plugin { "haproxy-typesdb":
    content => "TypesDB \"${typesdb}\"\n",
  }

  file { "haproxy collectd types":
    path    => $typesdb,
    content => "haproxy_backend   stot:COUNTER:0:U   bin:COUNTER:0:U   bout:COUNTER:0:U   econ:COUNTER:0:U   eresp:COUNTER:0:U   hrsp_1xx:COUNTER:0:U   hrsp_2xx:COUNTER:0:U   hrsp_3xx:COUNTER:0:U   hrsp_4xx:COUNTER:0:U   hrsp_5xx:COUNTER:0:U   hrsp_other:COUNTER:0:U\n",
  }

}

