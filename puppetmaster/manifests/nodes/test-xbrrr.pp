# VM
node 'test-xbrrr' inherits 'base-node' {

  class { 'c2corg::dev::env::symfony':
    developer => 'xbrrr',
    rootaccess => false, # already has root access on every node
  }

  fact::register {
    'role': value => ['apache', 'postgresql', 'dev'];
    'duty': value => 'dev';
  }

}
