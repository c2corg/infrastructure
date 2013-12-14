class c2corg::database::replication::master {

  include '::postgresql::params'

  $replication_user = hiera('replication_db_user')
  $replication_pass = hiera('replication_db_pass')

  postgresql::server::role { "${replication_user}":
    password_hash => postgresql_password($replication_user, $replication_pass),
    replication   => true,
  }

  postgresql::server::pg_hba_rule { 'allow replication access':
    database    => 'replication',
    user        => $replication_user,
    type        => 'hostssl',
    auth_method => 'md5',
    address     => '192.168.192.0/24',
    order       => '150',
  }

  postgresql::server::config_entry {
    'wal_level'         : value => 'hot_standby';
    'max_wal_senders'   : value => '5';
    'wal_keep_segments' : value => '32';
    'hot_standby'       : ensure => absent;
  }

  file { "${::postgresql::params::datadir}/recovery.conf":
    ensure => absent,
  }
}
