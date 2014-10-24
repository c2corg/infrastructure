# VM
node 'rproxy' {

  include c2cinfra::common
  include c2corg::varnish::instance

  fact::register {
    'role': value => ['varnish', 'reverse proxy'];
    'duty': value => 'prod';
  }
}
