# VM
node 'test-jose' inherits 'base-node' {

  class { 'c2corg::dev::env::symfony':
    developer => 'jose',
  }

  fact::register {
    'role': value => 'dev';
    'duty': value => 'dev';
  }

}
