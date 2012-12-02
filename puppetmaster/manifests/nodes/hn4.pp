# X3550 M3
node 'hn4' inherits 'base-node' {

  include c2cinfra::hn::hn4

  include c2corg::database::prod
  include c2cinfra::filesystem::postgres
  include c2corg::prod::env::postgres

  include memcachedb
  include c2cinfra::filesystem::memcachedb
  collectd::plugin { "memcached": lines => [] }

  include c2cinfra::collectd::node

  fact::register {
    'role': value => 'postgresql principal';
    'duty': value => 'prod';
  }

  $postgresql_backupfmt = "custom"
  include postgresql::backup
  c2cinfra::backup::dir { '/var/backups/pgsql': }

}
