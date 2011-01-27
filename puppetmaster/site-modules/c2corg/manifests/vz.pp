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

  vz::ve { "101": hname => "pm.c2corg" }

  vz::fwd { "forward puppetmaster port":
    ve   => "101",
    from => "8140",
    to   => "8140",
  }
  vz::fwd { "forward puppetmaster ssh port":
    ve   => "101",
    from => "10122",
    to   => "22",
  }

  /* mailing-lists */

  vz::ve { "102": hname => "lists.c2corg" }

  vz::fwd { "forward smtp port":
    ve   => "102",
    from => "25",
    to   => "25",
  }
  vz::fwd { "forward lists ssh port":
    ve   => "102",
    from => "10222",
    to   => "22",
  }

  /* test nodes */

  vz::ve { "123": hname => "test-marc.c2corg" }

  vz::fwd { "forward test-marc ssh port":
    ve   => "123",
    from => "10123",
    to   => "22",
  }

  vz::ve { "124":
    hname => "pre-prod.c2corg",
    template => "debian-squeeze-amd64-with-puppet",
  }

  vz::fwd { "forward pre-prod ssh port":
    ve   => "124",
    from => "10124",
    to   => "22",
  }

  vz::fwd { "forward pre-prod varnish port":
    ve   => "124",
    from => "80",
    to   => "8080",
  }

  vz::fwd { "forward pre-prod https port":
    ve   => "124",
    from => "443",
    to   => "443",
  }

  /* package repo */

  vz::ve { "125":
    hname => "pkg.c2corg",
    template => "debian-squeeze-amd64-with-puppet",
  }

  vz::fwd { "forward pkg ssh port":
    ve   => "125",
    from => "10125",
    to   => "22",
  }

  /* collectd, syslog, nagios */

  vz::ve { "126":
    hname => "monit.c2corg",
    template => "debian-squeeze-amd64-with-puppet",
  }

  vz::fwd { "forward monit ssh port":
    ve   => "126",
    from => "10126",
    to   => "22",
  }


}
