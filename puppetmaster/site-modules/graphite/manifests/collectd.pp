class graphite::collectd {

  vcsrepo { "/usr/src/collectd-graphite/":
    ensure   => present,
    provider => "git",
    source   => "git://github.com/joemiller/collectd-graphite.git",
    notify   => Exec["install collectd-graphite"],
  }

  exec { "install collectd-graphite":
    command   => "perl Makefile.PL && make && make test && make install",
    logoutput => true,
    cwd       => "/usr/src/collectd-graphite/",
    creates   => "/usr/local/share/perl/5.10.1/Collectd/Plugins/Graphite.pm",
    notify    => Service["collectd"],
  }

  collectd::plugin { "collectd-graphite":
    require => [Exec["install collectd-graphite"], Service["carbon-aggregator"]],
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
      Port   "2023"
    </Plugin>
</Plugin>
',
  }

}
