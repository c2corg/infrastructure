# VM - pre-prod database + webserver
node 'pre-prod' inherits 'base-node' {

  realize C2corg::Account::User['alex']
  realize C2corg::Account::User['xbrrr']
  realize C2corg::Account::User['gottferdom']
  realize C2corg::Account::User['gerbaux']

  include c2corg::database::preprod

  include c2corg::webserver::symfony::preprod
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::preprod
  include xcache

  include memcachedb

  include c2corg::varnish::instance

  include c2corg::collectd::client

}
