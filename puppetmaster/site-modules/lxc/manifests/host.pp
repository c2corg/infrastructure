class lxc::host {

  include nat

  # Ensure this matches what version is present in reprepro
  $livecfgver = '4.0~a8-1'

  $kernelver = '3.16-0.bpo.2'

  package { ['lxc', 'lxctl', 'bridge-utils', 'debootstrap']: ensure => present }


  apt::pin { 'kernel_and_initramfs_from_bpo':
    packages => "linux-image-${kernelver}-amd64 initramfs-tools",
    release  => "${::lsbdistcodename}-backports",
    priority => '1010',
  }

  package { "linux-image-${kernelver}-amd64": ensure => present }

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

  $pkgrepo = hiera('pkgrepo_host')
  $live_debconfig_url = "http://${pkgrepo}/c2corg/pool/main/l/live-debconfig/live-debconfig_${livecfgver}_all.deb"

  exec { 'fetch local live-debconfig package copy':
    command => "wget -P /usr/share/lxc/packages/ ${live_debconfig_url}",
    creates => "/usr/share/lxc/packages/live-debconfig_${livecfgver}_all.deb",
  } ->
  file { "/usr/share/lxc/packages/live-debconfig_${livecfgver}_all.deb":
    ensure => present,
  }

  c2cinfra::metrics::dir { "by-hardware-node/${::hostname}": }

}
