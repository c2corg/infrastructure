# PowerEdge 2950
node 'hn2' inherits 'base-node' {

  include c2cinfra::hn::hn2

  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  fact::register {
    'role': value => 'HN lxc';
    'duty': value => 'prod';
  }

}
