class c2corg::prod::fs::postgres {

# TODO: manage LVM & filesystems

  mount { "/var/lib/postgresql/8.4/main":
    ensure  => mounted,
    atboot  => true,
    device  => "/dev/mapper/vg0-pgdata",
    fstype  => "ext3",
    options => "noatime",
  }

  mount { "/var/lib/postgresql/8.4/main/pg_xlog":
    ensure  => mounted,
    atboot  => true,
    device  => "/dev/mapper/vg0-pgxlog",
    fstype  => "xfs",
    options => "noatime,nobarrier",
    require => Mount["/var/lib/postgresql/8.4/main"],
    before  => Service["postgresql"],
  }

  mount { "/var/backups/pgsql":
    ensure  => mounted,
    atboot  => true,
    device  => "/dev/mapper/vg0-pgbackup",
    fstype  => "ext3",
    options => "defaults",
  }

}
