class puppet::hiera {

  apt::preferences { "hiera-packages_from_c2corg_repo":
    package  => "ruby-hiera ruby-hiera-puppet",
    pin      => "release l=C2corg, a=${::lsbdistcodename}",
    priority => "1010",
  }

  package { ['ruby-hiera', 'ruby-hiera-puppet']:
    ensure => present,
  }

}
