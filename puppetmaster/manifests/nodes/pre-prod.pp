# VM
node 'pre-prod' inherits 'base-node' {

  realize C2cinfra::Account::User['alex']
  realize C2cinfra::Account::User['xbrrr']
  realize C2cinfra::Account::User['gottferdom']
  realize C2cinfra::Account::User['gerbaux']

  include c2corg::database::preprod

  include c2corg::webserver::symfony::preprod
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::preprod
  include xcache

  class {'memcached':
    max_memory => 32,
  }

  include c2corg::varnish::instance

  include c2cinfra::collectd::node

  fact::register {
    'role': value => 'pré-production';
    'duty': value => 'dev';
  }

}
