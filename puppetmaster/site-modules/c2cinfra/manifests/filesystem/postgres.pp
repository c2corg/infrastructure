class c2cinfra::filesystem::postgres {

  # /tmp
  logical_volume { "tmp":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "1G",
  }

  filesystem { "/dev/mapper/vg0-tmp":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["tmp"],
  }

  mount { "/tmp":
    ensure  => mounted,
    atboot  => true,
    fstype  => "ext3",
    options => "defaults",
    device  => "/dev/mapper/vg0-tmp",
    require => Filesystem["/dev/mapper/vg0-tmp"],
    before  => File["/tmp"],
  }


  # /var/log
  logical_volume { "log":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "3G",
  }

  filesystem { "/dev/mapper/vg0-log":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["log"],
  }

  mount { "/var/log":
    ensure  => mounted,
    atboot  => true,
    fstype  => "ext3",
    options => "defaults",
    device  => "/dev/mapper/vg0-log",
    require => Filesystem["/dev/mapper/vg0-log"],
  }


  # /var/lib/postgresql/NNN/main
  logical_volume { "pgdata":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "20G",
  }

  filesystem { "/dev/mapper/vg0-pgdata":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["pgdata"],
  }

  mount { "/var/lib/postgresql/8.4/main":
    ensure  => mounted,
    atboot  => true,
    device  => "/dev/mapper/vg0-pgdata",
    fstype  => "ext3",
    options => "noatime",
    require => Filesystem["/dev/mapper/vg0-pgdata"],
  }


  # /var/lib/postgresql/NNN/main/pg_xlog
  logical_volume { "pgxlog":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "5G",
  }

  filesystem { "/dev/mapper/vg0-pgxlog":
    ensure  => present,
    fs_type => "xfs",
    require => Logical_volume["pgxlog"],
  }

  mount { "/var/lib/postgresql/8.4/main/pg_xlog":
    ensure  => mounted,
    atboot  => true,
    device  => "/dev/mapper/vg0-pgxlog",
    fstype  => "xfs",
    options => "noatime,nobarrier",
    require => [
      Mount["/var/lib/postgresql/8.4/main"],
      Filesystem["/dev/mapper/vg0-pgxlog"],
    ],
    before  => Service["postgresql"],
  }


  # /var/backups/pgsql
  logical_volume { "pgbackup":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "10G",
  }

  filesystem { "/dev/mapper/vg0-pgbackup":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["pgbackup"],
  }

  mount { "/var/backups/pgsql":
    ensure  => mounted,
    atboot  => true,
    device  => "/dev/mapper/vg0-pgbackup",
    fstype  => "ext3",
    options => "defaults",
    require => Filesystem["/dev/mapper/vg0-pgbackup"],
  }

}
