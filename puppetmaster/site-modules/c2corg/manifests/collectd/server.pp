class c2corg::collectd::server inherits c2corg::collectd::node {

  resources { collectd_conf: purge => true; }

  Collectd::Network["network"] {
    listen => '"0.0.0.0" "25826"',
  }

  include haproxy::collectd::typesdb
  include c2corg::varnish::typesdb

  package { "thttpd":
    ensure => absent,
    before => Package["apache"],
  }

  file { "/var/www/cgi-bin/":
    ensure  => absent,
    recurse => true,
    force   => true,
  }

  package { 'drraw': require => Package['thttpd'] }

  $datadir = '/srv/carbon/rrd'
  common::line { "configure drraw rrd path":
    line    => "%datadirs = ( \"${datadir}\"  => \"[c2corg]\" );",
    file    => "/etc/drraw/drraw.conf",
    require => Package["drraw"],
  }

  file { "/var/www/${fqdn}/cgi-bin/drraw.cgi":
    mode    => 0755,
    ensure  => directory,
    source  => "file:///usr/lib/cgi-bin/drraw/drraw.cgi",
    require => Package["drraw"],
  }

}
