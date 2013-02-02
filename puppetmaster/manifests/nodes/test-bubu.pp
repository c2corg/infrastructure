# VM
node 'test-bubu' inherits 'base-node' {

  class { 'c2corg::dev::env::symfony':
    developer => 'bubu',
  }

  fact::register {
    'role': value => 'dev';
    'duty': value => 'dev';
  }

}
