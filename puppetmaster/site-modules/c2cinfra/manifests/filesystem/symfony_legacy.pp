class c2cinfra::filesystem::symfony_legacy {

  # /tmp
  logical_volume { "tmp":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "1G",
  }

  filesystem { "/dev/vg0/tmp":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["tmp"],
  }

  mount { "/tmp":
    ensure  => mounted,
    atboot  => true,
    fstype  => "ext3",
    options => "defaults",
    device  => "/dev/vg0/tmp",
    require => Filesystem["/dev/vg0/tmp"],
    before  => File["/tmp"],
  }


  # /var/www
  logical_volume { "www":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "5G",
  }

  filesystem { "/dev/vg0/www":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["www"],
  }

  mount { "/var/www":
    ensure  => mounted,
    atboot  => true,
    fstype  => "ext3",
    options => "defaults",
    device  => "/dev/vg0/www",
    require => Filesystem["/dev/vg0/www"],
  }


  # /var/log
  logical_volume { "log":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "2G",
  }

  filesystem { "/dev/vg0/log":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["log"],
  }

  mount { "/var/log":
    ensure  => mounted,
    atboot  => true,
    fstype  => "ext3",
    options => "defaults",
    device  => "/dev/vg0/log",
    require => Filesystem["/dev/vg0/log"],
  }


  # /srv/www
  logical_volume { "c2corg":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "1G",
  }

  filesystem { "/dev/vg0/c2corg":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["c2corg"],
  }

  mount { "/srv/www":
    ensure  => mounted,
    atboot  => true,
    options => "noatime",
    fstype  => "ext3",
    device  => "/dev/vg0/c2corg",
    require => [
      Filesystem["/dev/vg0/c2corg"],
      File["/srv/www"],
      Vcsrepo["/srv/www/camptocamp.org"],
    ],
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

  mount { "/srv/www/camptocamp.org/www-data/persistent":
    ensure  => mounted,
    atboot  => true,
    options => "noatime",
    fstype  => "ext3",
    device  => "/dev/vg0/persistent",
    require => [
      Mount["/srv/www"],
      Filesystem["/dev/vg0/persistent"],
      Vcsrepo["/srv/www/camptocamp.org"],
    ],
  }


  # /srv/www/camptocamp.org/volatile
  logical_volume { "volatile":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "30G",
  }

  filesystem { "/dev/vg0/volatile":
    ensure  => present,
    fs_type => "xfs",
    require => [Package["xfsprogs"], Logical_volume["volatile"]],
  }

  mount { "/srv/www/camptocamp.org/www-data/volatile":
    ensure  => mounted,
    atboot  => true,
    options => "noatime,nobarrier",
    fstype  => "xfs",
    device  => "/dev/vg0/volatile",
    require => [
      Mount["/srv/www"],
      Filesystem["/dev/vg0/volatile"],
      Vcsrepo["/srv/www/camptocamp.org"],
    ],
  }

}
