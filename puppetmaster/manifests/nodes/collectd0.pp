# VM
node 'collectd0' inherits 'base-node' {

  include '::graphite::carbon'
  include '::graphite::webapp'
  include '::statsd::server::nodejs'

  fact::register {
    'role': value => 'metrics collection';
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { [
    '/var/lib/graphite/whisper',
  ]: }

}
