class c2corg::prod::fs::memcachedb {

  logical_volume { "memcachedb":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "5G",
  }

  filesystem { "/dev/vg0/memcachedb":
    ensure  => present,
    fs_type => "xfs",
    require => [Logical_volume["memcachedb"], Package["xfsprogs"]],
  }

  mount { "/var/lib/memcachedb/":
    ensure  => mounted,
    options => "noatime,nobarrier",
    fstype  => "xfs",
    device  => "/dev/vg0/memcachedb",
    require => Filesystem["/dev/vg0/memcachedb"],
    before  => File["/var/lib/memcachedb"],
  }

}
