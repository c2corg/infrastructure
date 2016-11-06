class c2cinfra::apt {

  $debmirror = $::datacenter ? {
    /c2corg|epnet|pse/ => 'http://mirror.switch.ch/ftp/mirror',
    'gandi'        => 'http://mirrors.gandi.net',
    'ovh'          => 'http://debian.mirrors.ovh.net',
    default        => 'http://http.debian.net',
  }

  $pkgrepo = hiera('pkgrepo_host')

  apt::source { 'debian-squeeze':
    location  => "${debmirror}/debian/",
    release   => 'squeeze',
    repos     => 'main contrib non-free',
  }

  apt::source { 'debian-squeeze-security':
    location  => "http://security.debian.org/",
    release   => 'squeeze/updates',
    repos     => 'main contrib non-free',
  }

  apt::source { 'debian-squeeze-proposed-updates':
    location  => "${debmirror}/debian/",
    release   => 'squeeze-proposed-updates',
    repos     => 'main contrib non-free',
  }

  apt::source { 'debian-wheezy':
    location  => "${debmirror}/debian/",
    release   => 'wheezy',
    repos     => 'main contrib non-free',
  }

  apt::source { 'debian-wheezy-security':
    location  => "http://security.debian.org/",
    release   => 'wheezy/updates',
    repos     => 'main contrib non-free',
  }

  apt::source { 'debian-wheezy-proposed-updates':
    location  => "${debmirror}/debian/",
    release   => 'wheezy-proposed-updates',
    repos     => 'main contrib non-free',
  }

  apt::source { 'debian-jessie':
    location  => "${debmirror}/debian/",
    release   => 'jessie',
    repos     => 'main contrib non-free',
  }

  apt::source { 'debian-jessie-security':
    location  => "http://security.debian.org/",
    release   => 'jessie/updates',
    repos     => 'main contrib non-free',
  }

  apt::source { 'debian-jessie-proposed-updates':
    location  => "${debmirror}/debian/",
    release   => 'jessie-proposed-updates',
    repos     => 'main contrib non-free',
  }

  apt::source { 'c2corg':
    location  => "http://${pkgrepo}/c2corg/",
    release   => "${::lsbdistcodename}",
    repos     => 'main',
  }

  if ($::lsbdistrelease != 'testing') {
    apt::source { 'debian-backports':
      location => $::lsbdistcodename ? {
        'squeeze' => 'http://backports.debian.org/debian-backports',
        default   => "${debmirror}/debian/",
      },
      release   => "${::lsbdistcodename}-backports",
      repos     => 'main contrib non-free',
    }
  }

  if ($::lsbdistcodename =~ /wheezy|squeeze/ ) {
    apt::source { 'debian-backports-sloppy':
      location => "${debmirror}/debian/",
      release  => "${::lsbdistcodename}-backports-sloppy",
      repos    => 'main contrib non-free',
    }
  }

  # c2corg reprepro signing key
  apt::key { '6C074B04':
    key_source => "http://${pkgrepo}/pubkey.txt",
  }

  apt::pin { 'squeeze':
    packages => '*',
    codename => 'squeeze',
    priority => undef,
  }

  apt::pin { 'squeeze-proposed-updates':
    packages => '*',
    codename => 'squeeze-proposed-updates',
    priority => undef,
  }

  apt::pin { 'wheezy':
    packages => '*',
    codename => 'wheezy',
    priority => undef,
  }

  apt::pin { 'wheezy-proposed-updates':
    packages => '*',
    codename => 'wheezy-proposed-updates',
    priority => undef,
  }

  apt::pin { 'jessie':
    packages => '*',
    codename => 'jessie',
    priority => undef,
  }

  apt::pin { 'jessie-proposed-updates':
    packages => '*',
    codename => 'jessie-proposed-updates',
    priority => undef,
  }

  apt::pin { 'sid':
    packages => '*',
    codename => 'sid',
    priority => '20',
  }

  apt::pin { 'snapshots':
    packages => '*',
    origin   => 'snapshot.debian.org',
    priority => '10',
  }

  apt::pin { 'backports':
    packages => '*',
    release  => "${::lsbdistcodename}-backports",
    priority => '50',
  }

  apt::pin { 'backports-sloppy':
    packages => '*',
    release  => "${::lsbdistcodename}-backports-sloppy",
    priority => '50',
  }

  apt::pin { 'c2corg':
    packages => '*',
    release  => "${::lsbdistcodename}",
    label    => 'C2corg',
    priority => '110',
  }

  apt::conf { 'apt-cache-limit':
    ensure   => present,
    priority => '10',
    content  => 'APT::Cache-Limit 120000000;',
  }

  apt::conf { 'default-release':
    ensure   => present,
    priority => '01',
    content  => undef,
  }

  package { 'unattended-upgrades': ensure => present }

  if ($::lsbdistcodename =~ /wheezy|squeeze/ ) {
    apt::pin { 'backported_unattended-upgrades_version':
      packages => 'unattended-upgrades python-apt',
      release  => "${::lsbdistcodename}",
      label    => 'C2corg',
      priority => '1100',
    }
  }

  apt::conf { 'avoid-installing-unnecessary-stuff':
    ensure   => present,
    priority => '50',
    content  => '// file managed by puppet
APT::Install-Recommends "0";
APT::Install-Suggests "0";
',
  }

  # used in 50unattended-upgrades.erb
  if ($::lsbdistrelease == 'testing') {
    $pattern = 'a=testing'
    $extra = []
  } else {
    $pattern = "n=${::lsbdistcodename}"
    $extra = [
      "o=Debian Backports,n=${::lsbdistcodename}-backports",
      "o=Debian Backports,n=${::lsbdistcodename}-backports-sloppy"
    ]
  }

  apt::conf { 'unattended-upgrades':
    ensure   => present,
    priority => '50',
    content  => template('c2cinfra/apt/50unattended-upgrades.erb'),
  }

  apt::conf { 'cache-cleanup':
    ensure   => present,
    priority => '10',
    content  => '// file mananged by puppet
APT::Periodic::MaxSize "50";
APT::Periodic::MaxAge "7";
',
  }

  file { '/etc/apt/apt.conf.d/99unattended-upgrade':
    ensure => absent,
  }

}
