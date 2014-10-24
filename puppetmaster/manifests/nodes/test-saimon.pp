# VM
node 'test-saimon' {

  include c2cinfra::common
  class { 'c2corg::dev::env::plain':
    developer => 'saimon',
  }

  fact::register {
    'role': value => ['dev'];
    'duty': value => 'dev';
  }

  c2cinfra::backup::dir {
    ['/home']:
  }

}
