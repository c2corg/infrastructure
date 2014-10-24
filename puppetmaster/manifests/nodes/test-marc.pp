# VM
node 'test-marc' {

  include c2cinfra::common
  class { 'c2corg::dev::env::plain':
    developer => 'marc',
    rootaccess => false, # already has root access on every node
  }

  fact::register {
    'role': value => ['dev'];
    'duty': value => 'dev';
  }

  c2cinfra::backup::dir {
    ['/srv/www/camptocamp.org/', '/home']:
  }

}
