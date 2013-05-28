class c2cinfra::filesystem::openvz {

  logical_volume { "vz":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "10G",
  }

  filesystem { "/dev/vg0/vz":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["vz"],
  }

  mount { "/var/lib/vz":
    ensure  => mounted,
    options => "auto",
    fstype  => "ext3",
    device  => "/dev/vg0/vz",
    require => [Filesystem["/dev/vg0/vz"], Package["vzctl"]],
    before  => [File["/var/lib/vz"], Service["vz"]],
  }

}
