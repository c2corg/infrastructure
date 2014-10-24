# ProLiant DL360 G4p
node 'hn0' {

  include c2cinfra::common
  include c2cinfra::hn::hn0

  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  fact::register {
    'role': value => ['hn', 'lxc'];
    'duty': value => 'prod';
  }

}
