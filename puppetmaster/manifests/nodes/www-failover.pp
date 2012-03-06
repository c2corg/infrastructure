# VM - failover webserver, photo storage
node 'www-failover' inherits 'base-node' {

  realize C2corg::Account::User['alex']
  realize C2corg::Account::User['xbrrr']
  realize C2corg::Account::User['gottferdom']
  realize C2corg::Account::User['gerbaux']

  $haproxy_apache_address = "192.168.192.70"

  include c2corg::webserver::symfony::prod
  include c2corg::webserver::carto
  include c2corg::webserver::svg
  include c2corg::webserver::metaskirando

  include c2corg::apacheconf::prod
  include xcache

  include c2corg::prod::env::symfony
  include c2corg::prod::collectd::webserver

  include c2corg::prod::fs::photos

  include c2corg::collectd::client

  c2corg::backup::dir { "/srv/www/camptocamp.org/www-data/persistent": }

}
