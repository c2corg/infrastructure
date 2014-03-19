# hosted at ovh.net (91.121.221.105)
node 'backup0' inherits 'base-node' {

  include c2cinfra::hn::backup0
  include c2cinfra::filesystem::backup0
  include c2cinfra::backup::server

  class { 'c2cinfra::openvpn::client':
    username => 'backup0-vpn',
    password => hiera('backup0_vpn_password'),
  }

  fact::register {
    'role': value => ['backup offsite'];
    'duty': value => 'prod';
  }

}
