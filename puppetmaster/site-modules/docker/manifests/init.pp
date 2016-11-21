class docker {

  $docker_version = "1.12.3-0~${::lsbdistcodename}"
  $kernel_version = "4.7.0-0.bpo.1"

  apt::pin { 'kernel_from_bpo':
    packages => "linux-image-${kernel_version}-amd64 linux-base",
    release  => "${::lsbdistcodename}-backports",
    priority => '1010',
  } ->

  package { ["linux-image-${kernel_version}-amd64", 'firmware-linux-free', 'irqbalance', 'linux-base']:
    ensure => present,
  }

  apt::key { '58118E89F3A912897C070ADBF76221572C52609D':
    key_server => 'hkp://p80.pool.sks-keyservers.net:80',
  }

  apt::source { 'docker':
    location => 'https://apt.dockerproject.org/repo',
    release  => 'debian-jessie',
    repos    => 'main',
  } ->
  file { '/etc/systemd/system/docker.service.d/':
    ensure => directory,
  } ->
  file { '/etc/systemd/system/docker.service.d/override.conf':
    ensure  => present,
    notify  => Exec['systemctl-daemon-reload'],
    content => '# file managed by puppet
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon -H fd:// --storage-driver=overlay2 --log-driver=journald
',
  } ->
  package { 'docker-engine':
    ensure => "${docker_version}",
  } ->
  service { 'docker':
    enable => true,
    ensure => running,
  }

}
