# VM
node 'content-factory' inherits 'base-node' {

  include c2corg::database::dev

  include c2corg::webserver::symfony::content-factory
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::content-factory

  include c2cinfra::collectd::node

  include postgresql::backup

  fact::register {
    'role': value => 'pré-publication articles';
    'duty': value => 'dev';
  }

  c2corg::backup::dir { "/var/backups/pgsql": }

}
