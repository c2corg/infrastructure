class graphite {

  if (versioncmp($::operatingsystemrelease, 7) >= 0) {

    if ($::lsbdistcodename == 'wheezy') {
      apt::pin { 'backport graphite and carbon':
        packages => 'graphite-web graphite-carbon python-whisper libjs-jquery-flot python-django-tagging',
        label    => 'C2corg',
        release  => 'wheezy',
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
