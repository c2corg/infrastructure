# VM
node 'test-gottferdom' inherits 'base-node' {

  class { 'c2corg::dev::env::symfony':
    developer => 'gottferdom',
  }

  fact::register {
    'role': value => 'dev';
    'duty': value => 'dev';
  }

}
