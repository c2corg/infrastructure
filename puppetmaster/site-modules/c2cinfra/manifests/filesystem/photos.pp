class c2cinfra::filesystem::photos {

  # lvm created on openvz HN

  filesystem { "/dev/vg0/photos":
    ensure  => present,
    fs_type => "ext3",
  }

  mount { "/srv/www/camptocamp.org/www-data/persistent":
    ensure  => mounted,
    atboot  => true,
    device  => "/dev/vg0/photos",
    fstype  => "ext3",
    options => "noatime",
    require => [
      Filesystem["/dev/vg0/photos"],
      Vcsrepo["/srv/www/camptocamp.org"],
    ],
  }
}
