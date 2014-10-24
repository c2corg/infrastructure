# PowerEdge 2950
node 'hn2' {

  include c2cinfra::common
  include c2cinfra::hn::hn2

  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  fact::register {
    'role': value => ['hn', 'lxc'];
    'duty': value => 'prod';
  }

}
