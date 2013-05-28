# ProLiant DL360 G4p
node 'hn0' inherits 'base-node' {

  include c2cinfra::hn::hn0

  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  include c2cinfra::openvpn

  fact::register {
    'role': value => ['HN lxc', 'routeur'];
    'duty': value => 'prod';
  }

}
