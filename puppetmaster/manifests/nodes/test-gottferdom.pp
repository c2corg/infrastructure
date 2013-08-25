# VM
node 'test-gottferdom' inherits 'base-node' {

  class { 'c2corg::dev::env::symfony':
    developer => 'gottferdom',
  }

  fact::register {
    'role': value => ['apache', 'postgresql', 'dev'];
    'duty': value => 'dev';
  }

}
