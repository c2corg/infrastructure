# VM
node 'metrics' {

  include c2cinfra::common
  include '::graphite::carbon'
  include '::graphite::webapp'
  include '::statsd::server::nodejs'
  include '::c2cinfra::metrics::aliases'

  fact::register {
    'role': value => ['graphite', 'statsd'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { [
    '/var/lib/graphite',
  ]: }

}
