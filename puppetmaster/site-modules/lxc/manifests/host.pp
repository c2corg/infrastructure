class lxc::host {

  include nat

  # Ensure this matches what version is present in reprepro
  $livecfgver = '4.0~a8-1'

  package { ['lxc', 'lxctl', 'bridge-utils', 'debootstrap']: ensure => present }

  # backported from sid, unless they get included in wheezy
  apt::pin { 'lxc-packages_from_c2corg_repo':
    packages => 'lxc live-debconfig',
    label    => 'C2corg',
    release  => "${::lsbdistcodename}",
    priority => '1010',
  }

  file { '/cgroup': ensure => directory }

  mount { '/cgroup':
    ensure  => mounted,
    device  => 'cgroup',
    fstype  => 'cgroup',
    atboot  => true,
    options => 'defaults',
    require => File['/cgroup'],
  }

  etcdefault { 'set LXC dir':
    file  => 'lxc',
    key   => 'LXC_DIRECTORY',
    value => '/var/lib/lxc',
  }

  etcdefault { 'start LXC at boot':
    file  => 'lxc',
    key   => 'LXC_AUTO',
    value => 'true',
  }

  etcdefault { 'use lxc-shutdown when system stops':
    file  => 'lxc',
    key   => 'LXC_SHUTDOWN',
    value => 'shutdown',
  }

  # ensure lxc starts at boot
  service { 'lxc':
    ensure  => undef,
    enable  => true,
    require => Package['lxc'],
  }

  file { ['/usr/share/lxc/includes/', '/usr/share/lxc/packages/']:
    ensure  => directory,
    purge   => true,
    force   => true,
    recurse => true,
    require => Package['lxc'],
  }

  file { '/usr/share/lxc/includes/install-puppet.sh':
    source  => 'puppet:///modules/puppet/install-puppet.sh',
    mode    => 0755,
  }

  file { ['/usr/share/lxc/includes/root', '/usr/share/lxc/includes/root/.ssh']:
    ensure => directory,
    mode   => 0700,
  }

  file { '/usr/share/lxc/includes/root/.ssh/authorized_keys':
    ensure => present,
    source => 'file:///etc/ssh/authorized_keys/root.keys',
  }

  # not needed, just to be able to copy it from apt's cache
  package { 'live-debconfig':
    ensure => $livecfgver,
  }

  # hackish way to make live-debconfig.deb available to new containers
  file { "/usr/share/lxc/packages/live-debconfig_${livecfgver}_all.deb":
    source => "file:///var/cache/apt/archives/live-debconfig_${livecfgver}_all.deb",
    replace => false,
    require => Package['live-debconfig'],
  }

}
