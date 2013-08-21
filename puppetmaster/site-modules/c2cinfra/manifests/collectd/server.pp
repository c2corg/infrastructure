class c2cinfra::collectd::server inherits c2cinfra::collectd::node {

  Collectd::Config::Plugin['setup network plugin'] {
    settings => '
Listen "0.0.0.0" "25826"
ReportStats true
',
  }

  collectd::config::plugin { 'send metrics to carbon':
    plugin   => 'write_graphite',
    settings => '
<Carbon>
  Host "localhost"
  Port "2003"
  Protocol "udp"
  Prefix "collectd."
</Carbon>
',
  }

  @@nat::fwd { 'forward collectd port':
    host  => '127',
    from  => '25826',
    to    => '25826',
    proto => 'udp',
    tag   => 'portfwd',
  }
}
