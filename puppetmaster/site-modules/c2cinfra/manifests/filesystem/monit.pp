class c2cinfra::filesystem::monit {

  # lvm created on openvz HN

  filesystem { "/dev/vg0/monit":
    ensure  => present,
    fs_type => "ext3",
  }

  mount { "/srv":
    ensure  => mounted,
    atboot  => true,
    device  => "/dev/vg0/monit",
    fstype  => "ext3",
    options => "noatime",
    require => Filesystem["/dev/vg0/monit"],
  }
}
