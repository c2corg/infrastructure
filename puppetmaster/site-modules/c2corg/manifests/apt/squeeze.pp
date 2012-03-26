class c2corg::apt::squeeze inherits c2corg::apt {

  Apt::Preferences["squeeze"] {
    priority => "99",
  }

  Apt::Preferences["squeeze-proposed-updates"] {
    priority => "99",
  }

  Apt::Preferences["wheezy"] {
    priority => "50",
  }

  Apt::Preferences["wheezy-proposed-updates"] {
    priority => "50",
  }

  Apt::Conf["01default-release"] {
    content => 'APT::Default-Release "stable";', # warning: changing this can break the system !
  }

}
