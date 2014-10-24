# X3550 M3
node 'hn4' {

  include c2cinfra::common
  include c2cinfra::hn::hn4

  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  fact::register {
    'role': value => ['hn', 'lxc'];
    'duty': value => 'prod';
  }

}
