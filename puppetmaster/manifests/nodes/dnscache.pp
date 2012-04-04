# VM
node 'dnscache' inherits 'base-node' {

  include unbound

  fact::register {
    'role': value => 'cache DNS subnet privé';
    'duty': value => 'prod';
  }

}
