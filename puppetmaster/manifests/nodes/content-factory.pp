# VM
node 'content-factory' inherits 'base-node' {

  include c2corg::database::dev

  include c2corg::webserver::symfony::content-factory
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::content-factory
  include c2corg::webserver::metaskirando

  fact::register {
    'role': value => ['apache', 'postgresql', 'pre-publication'];
    'duty': value => 'preprod';
  }

  include c2cinfra::backup::postgresql
  c2cinfra::backup::dir { '/var/backups/pgsql': }

}
