# VM
node 'content-factory' inherits 'base-node' {

  include c2corg::database::dev

  include c2corg::webserver::symfony::content-factory
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::content-factory

  include c2cinfra::collectd::node

  fact::register {
    'role': value => 'pré-publication articles';
    'duty': value => 'dev';
  }

  class { 'postgresql::backup':
    backup_format => 'custom',
    backup_dir    => '/var/backups/pgsql',
  }

  c2cinfra::backup::dir { '/var/backups/pgsql': }

}
