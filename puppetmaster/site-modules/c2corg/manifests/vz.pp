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

  case $hostname {
    "hn0": {

      /* test nodes instanciation */
      #vz::ve { "201": hname => "test-alex.psea.infra.camptocamp.org" }
      #vz::ve { "202": hname => "test-xbrrr.psea.infra.camptocamp.org" }
      #vz::ve { "203": hname => "test-marc.psea.infra.camptocamp.org" }

      /*
       * port-forwards setup
       */

      vz::fwd {
        "forward puppetmaster port":     ve => "101", from => "8140",  to => "8140";
        "forward puppetmaster ssh port": ve => "101", from => "10101", to => "22";
      }

      vz::fwd {
        "forward lists smtp port": ve => "102", from => "25",    to => "25";
        "forward lists ssh port":  ve => "102", from => "10102", to => "22";
      }

      vz::fwd {
        "forward dev ssh port":   ve => "103", from => "10103", to => "22";
        "forward dev https port": ve => "103", from => "443",   to => "443";
        "forward dev http port":  ve => "103", from => "80",    to => "80";
      }

      vz::fwd {
        "forward pkg ssh port": ve => "125", from => "10125", to => "22";
      }

      vz::fwd {
        "forward monit ssh port": ve => "126", from => "10126", to => "22";
      }

      vz::fwd {
        "forward content-factory ssh port": ve => "140", from => "10140", to => "22";
      }

      vz::fwd {
        "forward pre-prod ssh port": ve => "141", from => "10141", to => "22";
      }

      vz::fwd {
        "forward test-alex ssh port": ve => "201", from => "10201", to => "22";
      }

      vz::fwd {
        "forward test-xbrrr ssh port": ve => "202", from => "10202", to => "22";
      }

      vz::fwd {
        "forward test-marc ssh port": ve => "203", from => "10203", to => "22";
      }
    }

    "hn2": {

      vz::ve { "101": hname => "pm.psea.infra.camptocamp.org" }
      vz::ve { "102": hname => "lists.psea.infra.camptocamp.org" }
      vz::ve { "103": hname => "dev.psea.infra.camptocamp.org" }
      vz::ve { "125": hname => "pkg.psea.infra.camptocamp.org" }
      vz::ve { "126": hname => "monit.psea.infra.camptocamp.org" }
      vz::ve { "140": hname => "content-factory.psea.infra.camptocamp.org" }
      vz::ve { "141": hname => "pre-prod.psea.infra.camptocamp.org" }

    }
  }

}
