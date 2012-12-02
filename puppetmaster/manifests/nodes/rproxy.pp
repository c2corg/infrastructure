# VM
node 'rproxy' inherits 'base-node' {

  include c2corg::varnish::instance

  include c2cinfra::collectd::node

  fact::register {
    'role': value => 'cache varnish';
    'duty': value => 'prod';
  }
}
