# VM
node 'memcache0' inherits 'base-node' {

  class {'memcached':
    max_memory => 32,
  }

  collectd::plugin { 'memcached': }

  fact::register {
    'role': value => ['memcache'];
    'duty': value => 'prod';
  }
}
