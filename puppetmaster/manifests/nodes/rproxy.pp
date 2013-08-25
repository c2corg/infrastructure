# VM
node 'rproxy' inherits 'base-node' {

  include c2corg::varnish::instance

  fact::register {
    'role': value => ['varnish', 'reverse proxy'];
    'duty': value => 'prod';
  }
}
