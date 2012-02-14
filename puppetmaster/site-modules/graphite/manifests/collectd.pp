class graphite::collectd {

  vcsrepo { "/usr/src/collectd-graphite/":
    ensure   => present,
    provider => "git",
    source   => "git://github.com/joemiller/collectd-graphite.git",
  }

  collectd::plugin { "collectd-graphite":
    require => [Vcsrepo["/usr/src/collectd-graphite/"], Service["carbon"]],
    content => '# file managed by puppet
<LoadPlugin "perl">
  Globals true
</LoadPlugin>

<Plugin "perl">
  BaseName "Collectd::Plugins"
  LoadPlugin "Graphite"

    <Plugin "Graphite">
      Buffer "256000"
      Prefix "collectd"
      Host   "localhost"
      Port   "2003"
    </Plugin>
</Plugin>
',
  }

}
