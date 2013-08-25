# xen VM hosted at gandi.net (95.142.173.157)
node 'backup' inherits 'base-node' {

  include c2cinfra::filesystem::backup
  include c2cinfra::backup::server
  include c2corg::webserver::ipv6gw

  class { 'c2cinfra::openvpn::client':
    username => 'backup-vpn',
    password => hiera('backup_vpn_password'),
  }

  fact::register {
    'role': value => ['backup offsite', 'proxy ipv6'];
    'duty': value => 'prod';
  }

}
