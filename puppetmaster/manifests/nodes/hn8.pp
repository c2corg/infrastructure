# PowerEdge 1950
node 'hn8' inherits 'base-node' {

  include c2cinfra::hn::hn8

  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  include '::c2cinfra::openvpn::server'

  C2cinfra::Account::User <| tag == 'trempoline' |>

  fact::register {
    'role': value => ['hn', 'lxc', 'router', 'ssh proxy'];
    'duty': value => 'prod';
  }

}
