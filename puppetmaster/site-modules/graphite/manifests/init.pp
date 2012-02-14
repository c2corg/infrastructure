class graphite {

  vcsrepo { "/usr/src/graphite":
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
