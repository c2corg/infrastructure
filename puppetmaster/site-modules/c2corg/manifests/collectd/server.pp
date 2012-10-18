class c2corg::collectd::server inherits c2corg::collectd::node {

  resources { collectd_conf: purge => true; }

  Collectd::Network["network"] {
    listen => '"0.0.0.0" "25826"',
  }

  include haproxy::collectd::typesdb
  include c2corg::varnish::typesdb

  package { 'drraw': ensure => absent }

  file { "/var/www/${fqdn}/cgi-bin/drraw.cgi": ensure  => absent }

  @@nat::fwd { 'forward collectd port':
    host  => '126',
    from  => '25826',
    to    => '25826',
    proto => 'udp',
    tag   => 'portfwd',
  }
}
