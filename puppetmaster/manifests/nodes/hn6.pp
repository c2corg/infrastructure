# PowerEdge 1850
node 'hn6' inherits 'base-node' {

  include c2cinfra::hn::hn6

  include c2cinfra::vip

  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  fact::register {
    'role': value => ['hn', 'lxc', 'haproxy', 'vip'];
    'duty': value => 'prod';
  }

}
