# PowerEdge 1850
node 'hn5' inherits 'base-node' {

  include c2corg::hn::hn5
  include c2corg::collectd::node

  class { 'c2corg::prod::fs::lxc': } ->
  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  fact::register {
    'role': value => 'HN lxc';
    'duty': value => 'prod';
  }

}
