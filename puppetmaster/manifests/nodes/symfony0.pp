# VM
node 'symfony0' {

  include c2cinfra::common
  realize C2cinfra::Account::User['alex']
  realize C2cinfra::Account::User['xbrrr']
  realize C2cinfra::Account::User['gottferdom']
  realize C2cinfra::Account::User['gerbaux']
  realize C2cinfra::Account::User['stef74']

  include c2corg::webserver::symfony::prod
  include c2corg::webserver::carto
  include c2corg::webserver::svg
  include c2corg::webserver::metaskirando

  include c2corg::apacheconf::prod
  include xcache

  include c2cinfra::filesystem::symfony
  include c2corg::prod::env::symfony
  include c2corg::prod::collectd::webserver

  fact::register {
    'role': value => ['apache', 'main web server'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { [
    '/srv/www/camptocamp.org/www-data/persistent/advertising',
    '/srv/www/camptocamp.org/www-data/persistent/avatars',
    '/srv/www/camptocamp.org/www-data/persistent/uploads/images',
  ]: }

}
