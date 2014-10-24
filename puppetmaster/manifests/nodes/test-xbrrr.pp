# VM
node 'test-xbrrr' {

  include c2cinfra::common
  class { 'c2corg::dev::env::symfony':
    developer => 'xbrrr',
    rootaccess => false, # already has root access on every node
  }

  fact::register {
    'role': value => ['apache', 'postgresql', 'dev'];
    'duty': value => 'dev';
  }

  c2cinfra::backup::dir {
    ['/srv/www/camptocamp.org/', '/home']:
  }

}
