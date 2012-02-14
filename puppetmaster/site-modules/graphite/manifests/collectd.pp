class graphite::collectd {

  vcsrepo { "/usr/src/collectd-graphite/":
    ensure   => present,
    provider => "git",
    source   => "git://github.com/joemiller/collectd-graphite.git",
  }

}
