# PowerEdge 1850
node 'hn5' inherits 'base-node' {

  include c2cinfra::hn::hn5
  include c2cinfra::collectd::node

  class { 'c2cinfra::filesystem::lxc': } ->
  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  fact::register {
    'role': value => 'HN lxc';
    'duty': value => 'prod';
  }

}
