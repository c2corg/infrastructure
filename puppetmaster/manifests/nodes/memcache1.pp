# VM
node 'memcache1' inherits 'base-node' {

  class {'memcached':
    max_memory => 32,
  }

  collectd::plugin { 'memcached': }

  fact::register {
    'role': value => 'instance memcached';
    'duty': value => 'prod';
  }
}
