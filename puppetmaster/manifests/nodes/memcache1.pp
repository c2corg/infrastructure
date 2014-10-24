# VM
node 'memcache1' {

  include c2cinfra::common
  class {'memcached':
    max_memory => 32,
  }

  collectd::plugin { 'memcached': }

  fact::register {
    'role': value => ['memcache'];
    'duty': value => 'prod';
  }
}
