# VM
node 'stats' inherits 'base-node' {

  include c2corg::stats
  include lxc::guest

  fact::register {
    'role': value => 'service stats utilisateurs';
    'duty': value => 'prod';
  }


}
