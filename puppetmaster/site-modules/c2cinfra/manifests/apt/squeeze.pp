class c2cinfra::apt::squeeze inherits c2cinfra::apt {

  Apt::Pin['squeeze'] {
    priority => '990',
  }

  Apt::Pin['squeeze-proposed-updates'] {
    priority => '990',
  }

  Apt::Pin['wheezy'] {
    priority => '50',
  }

  Apt::Pin['wheezy-proposed-updates'] {
    priority => '50',
  }

  Apt::Pin['jessie'] {
    priority => '50',
  }

  Apt::Pin['jessie-proposed-updates'] {
    priority => '50',
  }

  Apt::Conf['default-release'] {
    content => 'APT::Default-Release "oldoldstable";', # warning: changing this can break the system !
  }

  Apt::Source['debian-backports'] {
    ensure => absent,
  }

  Apt::Source['debian-backports-sloppy'] {
    ensure => absent,
  }

  apt::source { 'debian-squeeze-lts':
    location  => 'http://archive.debian.org/debian',
    release   => 'squeeze-lts',
    repos     => 'main contrib non-free',
  }

  apt::conf { 'check-valid-until':
    ensure   => present,
    priority => '10',
    content => 'Acquire::Check-Valid-Until false;',
  }

}
