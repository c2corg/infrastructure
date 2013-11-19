class puppet::hiera {

  apt::pin { 'hiera-packages_from_c2corg_repo':
    packages => 'ruby-hiera ruby-hiera-puppet',
    label    => 'C2corg',
    release  => "${::lsbdistcodename}",
    priority => '1010',
  }

  package { ['ruby-hiera', 'ruby-hiera-puppet']:
    ensure => present,
  }

}
