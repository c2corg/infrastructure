# xen VM hosted at gandi.net (46.226.111.1)
node 'ipv6proxy' {

  include c2cinfra::common
  include c2corg::webserver::ipv6gw

  class { 'c2cinfra::openvpn::client':
    username => 'ipv6proxy-vpn',
    password => hiera('ipv6proxy_vpn_password'),
  }

  fact::register {
    'role': value => ['proxy ipv6'];
    'duty': value => 'prod';
  }

}
