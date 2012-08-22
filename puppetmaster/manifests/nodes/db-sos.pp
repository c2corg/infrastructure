node 'db-sos' inherits 'base-node' {

  #include c2corg::database::prod
  #include c2corg::prod::env::postgres

  #include memcachedb
  #collectd::plugin { "memcached": lines => [] }

  include c2corg::collectd::node

  fact::register {
    'role': value => 'postgresql de secours';
    'duty': value => 'prod';
  }

  #$postgresql_backupfmt = "custom"
  #include postgresql::backup
  #c2corg::backup::dir { "/var/backups/pgsql": }

}
