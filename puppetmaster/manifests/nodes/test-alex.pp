# VM
node 'test-alex' {

  include c2cinfra::common
  class { 'c2corg::dev::env::symfony':
    developer => 'alex',
  }

  fact::register {
    'role': value => ['apache', 'postgresql', 'dev'];
    'duty': value => 'dev';
  }

  c2cinfra::backup::dir {
    ['/srv/www/camptocamp.org/', '/home']:
  }

}
