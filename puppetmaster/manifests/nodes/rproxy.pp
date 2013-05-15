# VM
node 'rproxy' inherits 'base-node' {

  include c2corg::varnish::instance

  fact::register {
    'role': value => 'cache varnish';
    'duty': value => 'prod';
  }
}
