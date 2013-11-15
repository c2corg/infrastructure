# X3550 M3
node 'hn4' inherits 'base-node' {

  include c2cinfra::hn::hn4

  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  fact::register {
    'role': value => ['hn', 'lxc'];
    'duty': value => 'prod';
  }

}
