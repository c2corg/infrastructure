class c2cinfra::containers {

  case $::hostname {
    'hn0': {

      vz::ve { '201': hname => 'test-alex.pse.infra.camptocamp.org' }
      vz::ve { '202': hname => 'test-xbrrr.pse.infra.camptocamp.org' }
      vz::ve { '203': hname => 'test-marc.pse.infra.camptocamp.org' }
      vz::ve { '204': hname => 'test-jose.pse.infra.camptocamp.org' }
      vz::ve { '205': hname => 'test-bubu.pse.infra.camptocamp.org' }
      vz::ve { '206': hname => 'test-saimon.pse.infra.camptocamp.org' }
      vz::ve { '221': hname => 'dev-cda.pse.infra.camptocamp.org' }

    }

    'hn2': {

      vz::ve { '50':  hname => 'dnscache.pse.infra.camptocamp.org' }
      vz::ve { '55':  hname => 'msgbroker.pse.infra.camptocamp.org' }
      vz::ve { '70':  hname => 'www-failover.pse.infra.camptocamp.org' }
      vz::ve { '101': hname => 'pm.pse.infra.camptocamp.org' }
      vz::ve { '102': hname => 'lists.pse.infra.camptocamp.org' }
      vz::ve { '103': hname => 'dev.pse.infra.camptocamp.org' }
      vz::ve { '125': hname => 'pkg.pse.infra.camptocamp.org' }
      vz::ve { '126': hname => 'monit.pse.infra.camptocamp.org' }
      vz::ve { '140': hname => 'content-factory.pse.infra.camptocamp.org' }
      vz::ve { '141': hname => 'pre-prod.pse.infra.camptocamp.org' }

    }

    'hn5': {

      lxc::container { 'rproxy.pse.infra.camptocamp.org':
        ctid   => 60,
        suite  => 'wheezy',
        fssize => '35G',
      }
    }

    'hn6': {

      lxc::container { 'stats.pse.infra.camptocamp.org':
        ctid   => 75,
        suite  => 'wheezy',
        fssize => '3G',
      }
    }

  }

}
