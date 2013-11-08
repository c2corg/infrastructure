class c2cinfra::backup::server {

  apt::sources_list { 'zfsonlinux':
    content => 'deb http://archive.zfsonlinux.org/debian wheezy main',
  }

  apt::key { 'A71C1E00': }

  # manually download and install this package from
  # http://mirrors.gandi.net/kernel/debs
  package { "linux-headers-${kernelversion}-xenu-${kernelversion}-amd64": } ->
  file { ["/lib/modules/${kernelrelease}/build", "/lib/modules/${kernelrelease}/source"]:
    ensure => link,
    target => "/usr/src/linux-headers-3.2.52-xenu-3.2.52-amd64/"
  } ->
  package { ['debian-zfs', 'zfsutils']: } ->
  etcdefault { 'mount ZFS at boot':
    file  => 'zfs',
    key   => 'ZFS_MOUNT',
    value => 'yes',
  }

  C2cinfra::Ssh::Userkey <<| tag == 'backups' |>>
  Zfs <<| tag == 'backups' |>>

  @@sshkey { $::ipaddress:
    type => rsa,
    key  => $::sshrsakey,
    ensure => absent,
  }

  cron { 'daily backup increment':
    command => '/usr/local/sbin/increment-backups.sh',
    hour    => 11,
    minute  => 20,
  }

  file { '/usr/local/sbin/increment-backups.sh':
    mode    => '0755',
    owner   => 'root',
    before  => Cron['daily backup increment'],
    require => Package['debian-zfs'],
    content => '#!/bin/sh

export PATH="/bin:/sbin"
BASE="srv/backups"
DATEFMT="%d"

NEWINCR=$(date +$DATEFMT)
OLDINCR=$(date -d "now - 10 days" +$DATEFMT)

for node in $(ls /$BASE); do
  if zfs list -t snapshot | egrep -q "^$BASE/$node@$OLDINCR"; then
    zfs destroy $BASE/$node@$OLDINCR
  fi

  zfs snapshot $BASE/$node@$NEWINCR
done

',
  }

}
