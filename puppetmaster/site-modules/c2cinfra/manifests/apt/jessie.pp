class c2cinfra::apt::jessie inherits c2cinfra::apt {

  Apt::Pin['squeeze'] {
    priority => '50',
  }

  Apt::Pin['squeeze-proposed-updates'] {
    priority => '50',
  }

  Apt::Pin['wheezy'] {
    priority => '50',
  }

  Apt::Pin['wheezy-proposed-updates'] {
    priority => '50',
  }

  Apt::Pin['jessie'] {
    priority => '990',
  }

  Apt::Pin['jessie-proposed-updates'] {
    priority => '990',
  }

  Apt::Conf['default-release'] {
    content => 'APT::Default-Release "testing";', # warning: changing this can break the system !
  }

}
