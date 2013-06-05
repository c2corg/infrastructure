class c2cinfra::apt::wheezy inherits c2cinfra::apt {

  Apt::Preferences["squeeze"] {
    priority => "50",
  }

  Apt::Preferences["squeeze-proposed-updates"] {
    priority => "50",
  }

  Apt::Preferences["wheezy"] {
    priority => "990",
  }

  Apt::Preferences["wheezy-proposed-updates"] {
    priority => "990",
  }

  Apt::Preferences["jessie"] {
    priority => "50",
  }

  Apt::Preferences["jessie-proposed-updates"] {
    priority => "50",
  }

  Apt::Conf["01default-release"] {
    content => 'APT::Default-Release "stable";', # warning: changing this can break the system !
  }

  # see debbug#711174
  apt::preferences { 'force working version of base-files':
    package  => 'base-files',
    pin      => 'release l=C2corg, a=wheezy',
    priority => '1100',
  }

}
