# X3550 M3
node 'hn3' inherits 'base-node' {

  include c2cinfra::hn::hn3

  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  fact::register {
    'role': value => ['hn', 'lxc'];
    'duty': value => 'prod';
  }

}
