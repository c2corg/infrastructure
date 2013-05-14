class c2cinfra::apt::squeeze inherits c2cinfra::apt {

  Apt::Preferences["squeeze"] {
    priority => "990",
  }

  Apt::Preferences["squeeze-proposed-updates"] {
    priority => "990",
  }

  Apt::Preferences["wheezy"] {
    priority => "50",
  }

  Apt::Preferences["wheezy-proposed-updates"] {
    priority => "50",
  }

  Apt::Preferences["jessie"] {
    priority => "50",
  }

  Apt::Preferences["jessie-proposed-updates"] {
    priority => "50",
  }

  Apt::Conf["01default-release"] {
    content => 'APT::Default-Release "oldstable";', # warning: changing this can break the system !
  }

}
