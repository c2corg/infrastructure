# VM - content-factory database + webserver
node 'content-factory' inherits 'base-node' {

  include c2corg::database::dev

  include c2corg::webserver::symfony::content-factory
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::content-factory

  include postgresql::backup
  c2corg::backup::dir { "/var/backups/pgsql": }

  include c2corg::collectd::client

}
