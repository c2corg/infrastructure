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
    max_memory => 16,
  }

  include c2corg::varnish::instance

  fact::register {
    'role': value => 'pré-production';
    'duty': value => 'dev';
  }

}
