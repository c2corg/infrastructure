class graphite {

  if (versioncmp($::operatingsystemrelease, 7) >= 0) {

    if ($::lsbdistcodename == 'wheezy') {
      apt::preferences { 'backport graphite and carbon':
        package  => 'graphite-web graphite-carbon python-whisper libjs-jquery-flot python-django-tagging',
        pin      => 'release l=C2corg, a=wheezy',
        priority => '1100',
      }
    }

  } else {

    vcsrepo { "/usr/src/graphite":
      ensure   => present,
      provider => "bzr",
      source   => "lp:graphite",
    }

    package { [
        "python-cairo",
        "python-django",
        "python-django-tagging",
        "python-memcache",
        "python-zope.interface",
        "python-whisper",
        "python-twisted-core",
      ]:
      ensure => present,
      before => Vcsrepo["/usr/src/graphite"],
    }
  }

}
