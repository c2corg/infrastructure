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

  sudoers { 'openvz admin':
    users => '%adm',
    type  => "user_spec",
    commands => [
      '(root) /usr/sbin/vzlist',
      '(root) /usr/sbin/vzctl',
      '(root) /usr/sbin/vzmemcheck',
      '(root) /usr/sbin/vzcpucheck',
      '(root) /usr/sbin/vzdqcheck',
      '(root) /usr/sbin/vzubc',
    ],
  }

  case $hostname {
    "hn0": {

      /* test nodes instanciation */
      vz::ve { "201": hname => "test-alex.pse.infra.camptocamp.org" }
      vz::ve { "202": hname => "test-xbrrr.pse.infra.camptocamp.org" }
      vz::ve { "203": hname => "test-marc.pse.infra.camptocamp.org" }
      vz::ve { "204": hname => "test-jose.pse.infra.camptocamp.org" }
      vz::ve { "205": hname => "test-bubu.pse.infra.camptocamp.org" }

      /*
       * port-forwards setup
       */

      vz::fwd {
        "forward puppetmaster port": ve => "101", from => "8140",  to => "8140";
      }

      vz::fwd {
        "forward lists smtp port": ve => "102", from => "25",    to => "25";
      }

      vz::fwd {
        "forward dev https port": ve => "103", from => "443",   to => "443";
        "forward dev http port":  ve => "103", from => "80",    to => "80";
      }

      vz::fwd {
        "forward puppetmaster ssh port":    ve => "101", from => "10101", to => "22";
        "forward lists ssh port":           ve => "102", from => "10102", to => "22";
        "forward dev ssh port":             ve => "103", from => "10103", to => "22";
        "forward pkg ssh port":             ve => "125", from => "10125", to => "22";
        "forward monit ssh port":           ve => "126", from => "10126", to => "22";
        "forward content-factory ssh port": ve => "140", from => "10140", to => "22";
        "forward pre-prod ssh port":        ve => "141", from => "10141", to => "22";
        "forward test-alex ssh port":       ve => "201", from => "10201", to => "22";
        "forward test-xbrrr ssh port":      ve => "202", from => "10202", to => "22";
        "forward test-marc ssh port":       ve => "203", from => "10203", to => "22";
        "forward test-jose ssh port":       ve => "204", from => "10204", to => "22";
        "forward test-bubu ssh port":       ve => "205", from => "10205", to => "22";
      }
    }

    "hn2": {

      vz::ve { "101": hname => "pm.pse.infra.camptocamp.org" }
      vz::ve { "102": hname => "lists.pse.infra.camptocamp.org" }
      vz::ve { "103": hname => "dev.pse.infra.camptocamp.org" }
      vz::ve { "125": hname => "pkg.pse.infra.camptocamp.org" }
      vz::ve { "126": hname => "monit.pse.infra.camptocamp.org" }
      vz::ve { "140": hname => "content-factory.pse.infra.camptocamp.org" }
      vz::ve { "141": hname => "pre-prod.pse.infra.camptocamp.org" }

    }
  }

}
