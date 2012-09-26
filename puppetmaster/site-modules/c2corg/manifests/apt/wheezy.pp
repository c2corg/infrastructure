class c2corg::apt::wheezy inherits c2corg::apt {

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

  Apt::Conf["01default-release"] {
    content => 'APT::Default-Release "testing";', # warning: changing this can break the system !
  }

}
