class app-vz-host {

  package { ["vzctl", "vzquota", "vzdump", "bridge-utils"]:
    ensure => present,
  }

  apt::preferences { "openvz-kernel":
     package  => "linux-image-2.6.32-4-openvz-amd64",
     pin      => "release a=unstable",
     priority => "1010",
  }

  package { "linux-image-2.6.32-4-openvz-amd64":
    ensure  => present,
    require => Apt::Preferences["openvz-kernel"],
  }

}
