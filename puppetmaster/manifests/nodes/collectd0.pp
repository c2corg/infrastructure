# VM
node 'collectd0' inherits 'base-node' {

  include '::graphite::carbon'
  include '::graphite::webapp'
  include '::statsd::server::nodejs'
  include '::c2cinfra::collectd::server'

  collectd::config::plugin { 'send metrics to carbon':
    plugin   => 'write_graphite',
    settings => '
<Carbon>
  Host "localhost"
  Port "2003"
  Prefix "collectd."
</Carbon>
',
  }

  fact::register {
    'role': value => 'metrics collection';
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { [
    '/var/lib/graphite/whisper',
  ]: }

}
