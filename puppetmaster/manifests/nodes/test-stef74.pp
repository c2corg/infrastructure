# VM
node 'test-stef74' inherits 'base-node' {

  class { 'c2corg::dev::env::plain':
    developer => 'stef74',
  }

  fact::register {
    'role': value => 'dev';
    'duty': value => 'dev';
  }

}
