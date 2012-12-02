# VM
node 'www-failover' inherits 'base-node' {

  realize C2cinfra::Account::User['alex']
  realize C2cinfra::Account::User['xbrrr']
  realize C2cinfra::Account::User['gottferdom']
  realize C2cinfra::Account::User['gerbaux']

  $haproxy_main_address = "192.168.192.70"

  include c2corg::webserver::symfony::prod
  include c2corg::webserver::carto
  include c2corg::webserver::svg
  include c2corg::webserver::metaskirando

  include c2corg::apacheconf::prod
  include xcache

  include c2corg::prod::env::symfony
  include c2corg::prod::collectd::webserver

  include c2corg::prod::fs::photos

  include c2cinfra::collectd::node

  fact::register {
    'role': value => ['failover', 'archivage photos'];
    'duty': value => 'prod';
  }

  c2corg::backup::dir { "/srv/www/camptocamp.org/www-data/persistent": }

}
