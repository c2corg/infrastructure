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

  apt::source { 'debian-squeeze-lts':
    location  => "${debmirror}/debian/",
    release   => 'squeeze-lts',
    repos     => 'main contrib non-free',
  }

}
