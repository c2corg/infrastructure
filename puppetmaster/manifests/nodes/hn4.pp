# X3550 M3 - prod database
node 'hn4' inherits 'base-node' {

  include c2corg::hn::hn4

  include c2corg::database::prod
  include c2corg::prod::fs::postgres
  include c2corg::prod::env::postgres

  include memcachedb
  include c2corg::prod::fs::memcachedb
  collectd::plugin { "memcached": lines => [] }

  include c2corg::collectd::client

  $postgresql_backupfmt = "custom"
  include postgresql::backup
  c2corg::backup::dir { "/var/backups/pgsql": }

}
