# VM
node 'dnscache' inherits 'base-node' {

  include unbound

  fact::register {
    'role': value => ['dns cache'];
    'duty': value => 'prod';
  }

}
