# X3550 M3 - prod webserver
node 'hn3' inherits 'base-node' {

  realize C2corg::Account::User['alex']
  realize C2corg::Account::User['xbrrr']
  realize C2corg::Account::User['gottferdom']
  realize C2corg::Account::User['gerbaux']

  $haproxy_vip_address = "128.179.66.23"
  $haproxy_cache_address = "192.168.192.2"
  $haproxy_main_address = "192.168.192.4"
  $haproxy_failover_address = "192.168.192.70"

  include c2corg::hn::hn3

  include c2corg::webserver::symfony::prod
  include c2corg::webserver::carto
  include c2corg::webserver::svg
  include c2corg::webserver::metaskirando

  include c2corg::apacheconf::prod
  include xcache

  include c2corg::prod::fs::symfony
  include c2corg::prod::env::symfony
  include c2corg::prod::collectd::webserver

  include haproxy
  include haproxy::collectd

  include c2corg::collectd::node

  c2corg::backup::dir { [
    "/srv/www/camptocamp.org/www-data/persistent/advertising",
    "/srv/www/camptocamp.org/www-data/persistent/avatars",
    "/srv/www/camptocamp.org/www-data/persistent/uploads/images",
  ]: }

  # preventive workaround, while trac#745 isn't properly fixed
  #host { "meta.camptocamp.org": ip => "127.0.0.2" }

}
