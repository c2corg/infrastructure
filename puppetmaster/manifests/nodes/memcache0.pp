# VM
node 'memcache0' inherits 'base-node' {

  class {'memcached':
    max_memory => 32,
  }

  include c2cinfra::collectd::node
  collectd::plugin { 'memcached': }

  fact::register {
    'role': value => 'instance memcached';
    'duty': value => 'prod';
  }
}
