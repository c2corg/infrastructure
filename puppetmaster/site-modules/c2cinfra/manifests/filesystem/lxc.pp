class c2cinfra::filesystem::lxc {

  logical_volume { 'lxc':
    ensure       => present,
    volume_group => 'vg0',
    initial_size => '3G',
  }

  filesystem { '/dev/vg0/lxc':
    ensure  => present,
    fs_type => 'ext4',
    require => Logical_volume['lxc'],
  }

  file { '/var/lib/lxc':
    ensure => directory,
    before => Mount['/var/lib/lxc'],
  }

  mount { '/var/lib/lxc':
    ensure  => mounted,
    atboot  => true,
    device  => '/dev/vg0/lxc',
    fstype  => 'ext4',
    options => 'defaults',
    require => Filesystem['/dev/vg0/lxc'],
  }

}
