class c2corg::collectd::server inherits c2corg::collectd::client {

  resources { collectd_conf: purge => true; }

  Collectd::Network["network"] {
    listen => '"0.0.0.0" "25826"',
  }

  include haproxy::collectd::typesdb
  include c2corg::varnish::typesdb


  # all the stuff below can be removed soon

  include thttpd

  # thttpd::conf { "nochroot": }

  # keep archive or RRD files in case we are able to read them back in graphite
  # some day.
  #tidy { "/srv/collectd":
  #  age     => "2w",
  #  recurse => true,
  #  rmdirs  => true,
  #}

  file { "/var/www/cgi-bin/":
    ensure  => directory,
    require => Package["thttpd"],
  }

  package { 'drraw': require => Package['thttpd'] }

  $datadir = '/srv/collectd'
  common::line { "configure drraw rrd path":
    line    => "%datadirs = ( \"${datadir}\"  => \"[c2corg]\" );",
    file    => "/etc/drraw/drraw.conf",
    require => Package["drraw"],
  }

  file { "/var/www/cgi-bin/drraw.cgi":
    mode    => 0755,
    ensure  => directory,
    source  => "file:///usr/lib/cgi-bin/drraw/drraw.cgi",
    require => Package["drraw"],
  }

}
