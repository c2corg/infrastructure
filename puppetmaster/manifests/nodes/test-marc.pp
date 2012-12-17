# VM
node 'test-marc' inherits 'base-node' {

  fact::register {
    'role': value => 'dev';
    'duty': value => 'dev';
  }

  sudoers { 'root access for marc':
    users    => 'marc',
    type     => 'user_spec',
    commands => '(ALL) ALL',
  }

  include c2corg::varnish::instance

  host {
    'symfony-backend.c2corg': ip => '192.168.192.4';
    'storage-backend.c2corg': ip => '192.168.192.70';
  }


}
