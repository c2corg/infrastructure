# PowerEdge 1950
node 'hn8' inherits 'base-node' {

  include c2cinfra::hn::hn8

  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  fact::register {
    'role': value => 'HN lxc';
    'duty': value => 'prod';
  }

}
