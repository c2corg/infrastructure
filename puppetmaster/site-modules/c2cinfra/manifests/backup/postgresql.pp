class c2cinfra::backup::postgresql {

  file { '/var/backups/pgsql':
    ensure  => directory,
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0755',
    require => Class['postgresql::server'],
  } ->

  file { '/usr/local/bin/pgsql-backup.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/c2cinfra/backup/pgsql-backup.sh',
  } ->

  cron { 'pgsql-backup':
    command => '/usr/local/bin/pgsql-backup.sh',
    user    => 'postgres',
    hour    => 2,
    minute  => 0,
  }

}
