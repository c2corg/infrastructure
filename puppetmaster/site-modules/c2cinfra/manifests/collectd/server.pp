class c2cinfra::collectd::server inherits c2cinfra::collectd::node {

  Collectd::Config::Plugin['setup network plugin'] {
    settings => '
Listen "0.0.0.0" "25826"
CacheFlush 86400
',
  }

  @@nat::fwd { 'forward collectd port':
    host  => '126',
    from  => '25826',
    to    => '25826',
    proto => 'udp',
    tag   => 'portfwd',
  }
}
