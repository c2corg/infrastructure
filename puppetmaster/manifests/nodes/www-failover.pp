# VM
node 'www-failover' {

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

  include c2corg::prod::env::symfony
  include c2corg::prod::collectd::webserver

  include c2corg::mailinglists::webfetch

  fact::register {
    'role': value => ['apache', 'failover web server', 'media storage'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { '/srv/www/camptocamp.org/www-data/persistent': }

}
