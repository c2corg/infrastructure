class c2cinfra::filesystem::symfony {

  Mknod <<| tag == $::hostname |>> ->

  # /var/www
  filesystem { '/dev/varwww':
    ensure  => present,
    fs_type => 'ext4',
  } ->

  mount { '/var/www':
    ensure  => mounted,
    atboot  => true,
    fstype  => 'ext4',
    options => 'defaults',
    device  => '/dev/varwww',
  } ->


  # /srv/www
  filesystem { '/dev/srvwww':
    ensure  => present,
    fs_type => 'ext4',
  } ->

  mount { '/srv/www':
    ensure  => mounted,
    atboot  => true,
    options => 'noatime',
    fstype  => 'ext4',
    device  => '/dev/srvwww',
    require => [
      File['/srv/www'],
      Vcsrepo['/srv/www/camptocamp.org'],
    ],
  } ->


  # /srv/www/camptocamp.org/persistent
  filesystem { '/dev/persistent':
    ensure  => present,
    fs_type => 'ext4',
  } ->

  mount { '/srv/www/camptocamp.org/www-data/persistent':
    ensure  => mounted,
    atboot  => true,
    options => 'noatime',
    fstype  => 'ext4',
    device  => '/dev/persistent',
    require => [
      Mount['/srv/www'],
      Vcsrepo['/srv/www/camptocamp.org'],
    ],
  } ->


  # /srv/www/camptocamp.org/volatile
  filesystem { '/dev/volatile':
    ensure  => present,
    fs_type => 'xfs',
    require => Package['xfsprogs'],
  } ->

  mount { '/srv/www/camptocamp.org/www-data/volatile':
    ensure  => mounted,
    atboot  => true,
    options => 'noatime,nobarrier',
    fstype  => 'xfs',
    device  => '/dev/volatile',
    require => [
      Mount['/srv/www'],
      Vcsrepo['/srv/www/camptocamp.org'],
    ],
  }

}
