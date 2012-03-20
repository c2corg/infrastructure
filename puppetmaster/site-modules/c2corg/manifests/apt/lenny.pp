class c2corg::apt::lenny inherits c2corg::apt {

  Apt::Preferences["lenny"] {
    priority => "99",
  }

  Apt::Preferences["lenny-proposed-updates"] {
    priority => "99",
  }

  Apt::Preferences["squeeze"] {
    priority => "50",
  }

  Apt::Preferences["squeeze-proposed-updates"] {
    priority => "50",
  }

  Apt::Preferences["wheezy"] {
    priority => "40",
  }

  Apt::Preferences["wheezy-proposed-updates"] {
    priority => "40",
  }

  Apt::Conf["01default-release"] {
    content => 'APT::Default-Release "oldstable";', # warning: changing this can break the system !
  }

  apt::sources_list { "debian-volatile":
    content => "# file managed by puppet
deb http://volatile.debian.org/debian-volatile ${lsbdistcodename}/volatile main
",
  }

  apt::preferences { "augeas_from_backports":
    package  => "augeas-tools libaugeas0 augeas-lenses libaugeas-ruby1.8",
    pin      => "release a=${lsbdistcodename}-backports",
    priority => "1010",
  }

  apt::preferences { "haproxy_from_backports":
    package  => "haproxy",
    pin      => "release a=${lsbdistcodename}-backports",
    priority => "1010",
  }

  apt::preferences { "git_from_backports":
    package  => "git git-core git-svn",
    pin      => "release a=${lsbdistcodename}-backports",
    priority => "1010",
  }

}
