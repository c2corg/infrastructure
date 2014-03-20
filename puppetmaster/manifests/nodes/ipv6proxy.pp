# xen VM hosted at gandi.net (46.226.111.1)
node 'ipv6proxy' inherits 'base-node' {

  include c2corg::webserver::ipv6gw

  fact::register {
    'role': value => ['proxy ipv6'];
    'duty': value => 'prod';
  }

}
