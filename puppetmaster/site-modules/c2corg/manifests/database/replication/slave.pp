class c2corg::database::replication::slave {

  # reinit replication with:
  # service postgresql stop
  # su - postgres
  # rm -fr ./main
  # pg_basebackup -P -v -D ./main --user=replication --port=5432 --host=nn.nn.nn.nn
  # puppet agent -t

  include '::postgresql::params'

  $replication_master = hiera('db_replication_master_host')

  $replication_user = hiera('replication_db_user')
  $replication_pass = hiera('replication_db_pass')

  postgresql::server::config_entry {
    'hot_standby'       : value => 'on';
    'wal_level'         : ensure => absent;
    'max_wal_senders'   : ensure => absent;
    'wal_keep_segments' : ensure => absent;
  }

  file { "${::postgresql::params::datadir}/recovery.conf":
    content => "# file managed by puppet
standby_mode     = 'on'
primary_conninfo = 'host=${replication_master} port=5432 user=${replication_user} password=${replication_pass}'
",
  }
}
