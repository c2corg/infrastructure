# X3550 M3
node 'hn3' inherits 'base-node' {

  realize C2cinfra::Account::User['alex']
  realize C2cinfra::Account::User['xbrrr']
  realize C2cinfra::Account::User['gottferdom']
  realize C2cinfra::Account::User['gerbaux']

  $c2corg_vip            = hiera('c2corg_vip')
  $varnish_host          = hiera('varnish_host')
  $symfony_master_host   = hiera('symfony_master_host')
  $symfony_failover_host = hiera('symfony_failover_host')

  include c2cinfra::hn::hn3

  include c2corg::webserver::symfony::prod
  include c2corg::webserver::carto
  include c2corg::webserver::svg
  include c2corg::webserver::metaskirando

  include c2corg::apacheconf::prod
  include xcache

  include c2cinfra::filesystem::symfony
  include c2corg::prod::env::symfony
  include c2corg::prod::collectd::webserver

  include c2cinfra::collectd::node

  fact::register {
    'role': value => 'serveur web principal';
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { [
    '/srv/www/camptocamp.org/www-data/persistent/advertising',
    '/srv/www/camptocamp.org/www-data/persistent/avatars',
    '/srv/www/camptocamp.org/www-data/persistent/uploads/images',
  ]: }

  # preventive workaround, while trac#745 isn't properly fixed
  #host { "meta.camptocamp.org": ip => "127.0.0.2" }

}
