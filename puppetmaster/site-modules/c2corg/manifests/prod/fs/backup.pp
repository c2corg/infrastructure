class c2corg::prod::fs::backup {

  filesystem { "/dev/xvdd":
    ensure  => present,
    fs_type => "btrfs",
    require => [Package["btrfs-tools"]],
  }

  mount { "/srv/backups":
    ensure  => mounted,
    options => "noatime",
    fstype  => "btrfs",
    device  => "/dev/xvdd",
    require => Filesystem["/dev/xvdd"],
  }

}
