class phantomjs {

  apt::pin { 'phanomjs_from_c2corg_repo':
    packages => 'phantomjs',
    label    => 'C2corg',
    priority => '1010',
  }

  apt::pin { 'libjs-coffeescript_from_bpo':
    packages => 'libjs-coffeescript',
    release  => "${::lsbdistcodename}-backports",
    priority => '1010',
  }

  package { 'phantomjs': ensure => present }
}
