/*
OpenVZ node + firewall definition

*/
class c2corg::vz {

  collectd::plugin { "openvz":
    content => '# file managed by puppet
<LoadPlugin "perl">
  Globals true
</LoadPlugin>

<Plugin "perl">
  BaseName "Collectd::Plugins"
  LoadPlugin "OpenVZ"
</Plugin>
',
  }

  /* puppetmaster */

  vz::ve { "101": hname => "pm.psea.infra.camptocamp.org" }

  vz::fwd { "forward puppetmaster port":
    ve   => "101",
    from => "8140",
    to   => "8140",
  }
  vz::fwd { "forward puppetmaster ssh port":
    ve   => "101",
    from => "10101",
    to   => "22",
  }

  /* mailing-lists */

  vz::ve { "102": hname => "lists.psea.infra.camptocamp.org", ensure => stopped }

  vz::fwd { "forward smtp port":
    ve   => "102",
    from => "25",
    to   => "25",
  }
  vz::fwd { "forward lists ssh port":
    ve   => "102",
    from => "10102",
    to   => "22",
  }

  /* dev */

  vz::ve { "103":
    hname => "dev.psea.infra.camptocamp.org",
    template => "debian-squeeze-amd64-with-puppet",
  }

  vz::fwd { "forward dev ssh port":
    ve   => "103",
    from => "10103",
    to   => "22",
  }

  vz::fwd { "forward dev https port":
    ve   => "103",
    from => "443",
    to   => "443",
  }

  vz::fwd { "forward dev http port":
    ve   => "103",
    from => "80",
    to   => "80",
  }

  /* package repo */

  vz::ve { "125":
    hname => "pkg.psea.infra.camptocamp.org",
    template => "debian-squeeze-amd64-with-puppet",
  }

  vz::fwd { "forward pkg ssh port":
    ve   => "125",
    from => "10125",
    to   => "22",
  }

  #vz::fwd { "forward pkg http port":
  #  ve   => "125",
  #  from => "8083",
  #  to   => "80",
  #}

  /* collectd, syslog, nagios */

  vz::ve { "126":
    hname => "monit.psea.infra.camptocamp.org",
    template => "debian-squeeze-amd64-with-puppet",
  }

  vz::fwd { "forward monit ssh port":
    ve   => "126",
    from => "10126",
    to   => "22",
  }

  /* integration/pre-prod nodes */

  vz::ve { "140":
    hname => "content-factory.psea.infra.camptocamp.org",
    template => "debian-squeeze-amd64-with-puppet",
  }

  vz::fwd { "forward content-factory ssh port":
    ve   => "140",
    from => "10140",
    to   => "22",
  }

  #vz::fwd { "forward content-factory http port":
  #  ve   => "140",
  #  from => "8081",
  #  to   => "80",
  #}

  vz::ve { "141":
    hname => "pre-prod.psea.infra.camptocamp.org",
    template => "debian-squeeze-amd64-with-puppet",
  }

  vz::fwd { "forward pre-prod ssh port":
    ve   => "141",
    from => "10141",
    to   => "22",
  }

  #vz::fwd { "forward pre-prod varnish port":
  #  ve   => "141",
  #  from => "80",
  #  to   => "8080",
  #}

  #vz::fwd { "forward pre-prod https port":
  #  ve   => "141",
  #  from => "8443",
  #  to   => "443",
  #}

  /* test nodes */

  vz::ve { "201":
    hname => "test-alex.psea.infra.camptocamp.org",
    template => "debian-squeeze-amd64-with-puppet",
    ensure => stopped,
  }

  vz::fwd { "forward test-alex ssh port":
    ve   => "201",
    from => "10201",
    to   => "22",
  }

  #vz::fwd { "forward test-alex http port":
  #  ve   => "201",
  #  from => "11201",
  #  to   => "80",
  #}

  vz::ve { "202":
    hname => "test-xbrrr.psea.infra.camptocamp.org",
    template => "debian-squeeze-amd64-with-puppet",
    ensure => stopped,
  }

  vz::fwd { "forward test-xbrrr ssh port":
    ve   => "202",
    from => "10202",
    to   => "22",
  }

  #vz::fwd { "forward test-xbrrr http port":
  #  ve   => "202",
  #  from => "11202",
  #  to   => "80",
  #}

  vz::ve { "203":
    hname => "test-marc.psea.infra.camptocamp.org",
    template => "debian-squeeze-amd64-with-puppet",
    ensure => stopped,
  }

  vz::fwd { "forward test-marc ssh port":
    ve   => "203",
    from => "10203",
    to   => "22",
  }


}
