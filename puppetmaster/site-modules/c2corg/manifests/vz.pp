/*
OpenVZ node + firewall definition

*/
class c2corg::vz {

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

  case $::hostname {
    "hn0": {

      /* test nodes instanciation */
      vz::ve { "201": hname => "test-alex.pse.infra.camptocamp.org" }
      vz::ve { "202": hname => "test-xbrrr.pse.infra.camptocamp.org" }
      vz::ve { "203": hname => "test-marc.pse.infra.camptocamp.org" }
      vz::ve { "204": hname => "test-jose.pse.infra.camptocamp.org" }
      vz::ve { "205": hname => "test-bubu.pse.infra.camptocamp.org" }
      vz::ve { "206": hname => "test-saimon.pse.infra.camptocamp.org" }
      vz::ve { "221": hname => "dev-cda.pse.infra.camptocamp.org" }

      /*
       * port-forwards setup
       */

      nat::fwd {
        "forward puppetmaster port":    host => "101", from => "8140",  to => "8140";
      }

      nat::fwd {
        "forward lists smtp port":      host => "102", from => "25",    to => "25";
      }

      nat::fwd {
        "forward monit syslog port":    host => "126", from => "514",   to => "514";
        "forward monit collectd port":  host => "126", from => "25826", to => "25826", proto => "udp";
      }

      nat::fwd {
        "forward dev https port":       host => "103", from => "443",   to => "443";
        "forward dev http port":        host => "103", from => "80",    to => "80";
      }

      # TODO: enable SSL before
      #nat::fwd {
      #  "forward stomp port"            host => "55",  from => "61613", to => "61613";
      #}

      nat::fwd {
        "forward dnscache ssh port":        host => "50",  from => "1050",  to => "22";
        "forward msgbroker ssh port":       host => "55",  from => "1055",  to => "22";
        "forward www-failover ssh port":    host => "70",  from => "1070",  to => "22";
        "forward puppetmaster ssh port":    host => "101", from => "10101", to => "22";
        "forward lists ssh port":           host => "102", from => "10102", to => "22";
        "forward dev ssh port":             host => "103", from => "10103", to => "22";
        "forward pkg ssh port":             host => "125", from => "10125", to => "22";
        "forward monit ssh port":           host => "126", from => "10126", to => "22";
        "forward content-factory ssh port": host => "140", from => "10140", to => "22";
        "forward pre-prod ssh port":        host => "141", from => "10141", to => "22";
        "forward test-alex ssh port":       host => "201", from => "10201", to => "22";
        "forward test-xbrrr ssh port":      host => "202", from => "10202", to => "22";
        "forward test-marc ssh port":       host => "203", from => "10203", to => "22";
        "forward test-jose ssh port":       host => "204", from => "10204", to => "22";
        "forward test-bubu ssh port":       host => "205", from => "10205", to => "22";
        "forward test-saimon ssh port":     host => "206", from => "10206", to => "22";
        "forward dev-cda ssh port":         host => "221", from => "10221", to => "22";
      }
    }

    "hn2": {

      vz::ve { "50":  hname => "dnscache.pse.infra.camptocamp.org" }
      vz::ve { "55":  hname => "msgbroker.pse.infra.camptocamp.org" }
      vz::ve { "70":  hname => "www-failover.pse.infra.camptocamp.org" }
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
