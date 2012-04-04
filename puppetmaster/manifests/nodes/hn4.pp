# X3550 M3
node 'hn4' inherits 'base-node' {

  include c2corg::hn::hn4

  include c2corg::database::prod
  include c2corg::prod::fs::postgres
  include c2corg::prod::env::postgres

  include memcachedb
  include c2corg::prod::fs::memcachedb
  collectd::plugin { "memcached": lines => [] }

  include c2corg::collectd::node

  fact::register { 'role': value => 'postgresql principal' }

  $postgresql_backupfmt = "custom"
  include postgresql::backup
  c2corg::backup::dir { "/var/backups/pgsql": }

}
