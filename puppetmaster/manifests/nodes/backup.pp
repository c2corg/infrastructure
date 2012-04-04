# xen VM hosted at gandi.net (95.142.173.157)
node 'backup' inherits 'base-node' {

  include c2corg::prod::fs::backup
  include c2corg::backup::server
  include c2corg::webserver::ipv6gw
  include c2corg::collectd::node

  fact::register {
    'role': value => ['backup offsite', 'proxy ipv6'];
    'duty': value => 'prod';
  }

  collectd::plugin { ['cpu', 'df', 'disk', 'swap']: lines => [] }

}
