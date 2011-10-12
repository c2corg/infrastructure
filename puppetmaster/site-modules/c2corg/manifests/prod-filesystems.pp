class c2corg::prod::filesystems::varnish {
}

class c2corg::prod::filesystems::postgres {

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

class c2corg::prod::filesystems::symfony {

  # TODO: stash logs in a dedicated partition

  # /srv/www
  logical_volume { "www":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "10G",
  }

  filesystem { "/dev/vg0/www":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["www"],
  }

  mount { "/srv/www":
    ensure  => mounted,
    atboot  => true,
    options => "noatime",
    fstype  => "ext3",
    device  => "/dev/vg0/www",
    require => [Filesystem["/dev/vg0/www"], File["/srv/www"]],
    before  => [Vcsrepo["/srv/www/camptocamp.org"], Vcsrepo["/srv/www/meta.camptocamp.org"]],
  }

  # /srv/www/camptocamp.org/persistent
  logical_volume { "persistent":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "80G",
  }

  filesystem { "/dev/vg0/persistent":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["persistent"],
  }

  mount { "/srv/www/camptocamp.org/persistent":
    ensure  => mounted,
    atboot  => true,
    options => "noatime",
    fstype  => "ext3",
    device  => "/dev/vg0/persistent",
    require => [Filesystem["/dev/vg0/persistent"], Vcsrepo["/srv/www/camptocamp.org"]],
  }

  # /srv/www/camptocamp.org/volatile
  logical_volume { "volatile":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "40G",
  }

  filesystem { "/dev/vg0/volatile":
    ensure  => present,
    fs_type => "xfs",
    require => Logical_volume["volatile"],
  }

  mount { "/srv/www/camptocamp.org/volatile":
    ensure  => mounted,
    atboot  => true,
    options => "noatime,nobarrier",
    fstype  => "xfs",
    device  => "/dev/vg0/volatile",
    require => [Filesystem["/dev/vg0/volatile"], Vcsrepo["/srv/www/camptocamp.org"]],
  }

}
