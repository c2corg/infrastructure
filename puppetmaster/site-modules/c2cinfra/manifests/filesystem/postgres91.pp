class c2cinfra::filesystem::postgres91 {

  Mknod <<| tag == $::hostname |>> ->

  # /var/lib/postgresql/NNN/main
  filesystem { '/dev/pgdata':
    ensure  => present,
    fs_type => 'ext4',
  } ->

  mount { '/var/lib/postgresql/9.1/main':
    ensure  => mounted,
    atboot  => true,
    device  => '/dev/pgdata',
    fstype  => 'ext4',
    options => 'noatime',
  } ->

  # /var/lib/postgresql/NNN/main/pg_xlog
  filesystem { '/dev/pgxlog':
    ensure  => present,
    fs_type => 'ext4',
  } ->

  mount { '/var/lib/postgresql/9.1/main/pg_xlog':
    ensure  => mounted,
    atboot  => true,
    device  => '/dev/pgxlog',
    fstype  => 'ext4',
    options => 'noatime,nobarrier',
    before  => Service['postgresql'],
  } ->

  # /var/log/postgresql
  filesystem { '/dev/pglog':
    ensure  => present,
    fs_type => 'ext4',
  } ->

  mount { '/var/log/postgresql':
    ensure  => mounted,
    atboot  => true,
    device  => '/dev/pglog',
    fstype  => 'ext4',
    options => 'noatime,nobarrier',
  } ->

  # /var/backups/pgsql
  filesystem { '/dev/pgbackup':
    ensure  => present,
    fs_type => 'ext4',
  } ->

  mount { '/var/backups/pgsql':
    ensure  => mounted,
    atboot  => true,
    device  => '/dev/pgbackup',
    fstype  => 'ext4',
    options => 'defaults',
  }

}
