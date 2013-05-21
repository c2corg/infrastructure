class c2cinfra::containers {

  case $::hostname {
    'hn0': {

      vz::ve { '201': hname => 'test-alex.pse.infra.camptocamp.org' }
      vz::ve { '202': hname => 'test-xbrrr.pse.infra.camptocamp.org' }
      vz::ve { '203': hname => 'test-marc.pse.infra.camptocamp.org' }
      vz::ve { '204': hname => 'test-jose.pse.infra.camptocamp.org', ensure => absent }
      vz::ve { '205': hname => 'test-bubu.pse.infra.camptocamp.org', ensure => absent }
      vz::ve { '206': hname => 'test-saimon.pse.infra.camptocamp.org' }
      vz::ve { '207': hname => 'test-gottferdom.pse.infra.camptocamp.org' }

    }

    'hn2': {

      vz::ve { '50':  hname => 'dnscache.pse.infra.camptocamp.org', ensure => absent }
      vz::ve { '55':  hname => 'msgbroker.pse.infra.camptocamp.org', ensure => absent }
      vz::ve { '70':  hname => 'www-failover.pse.infra.camptocamp.org' }
      vz::ve { '101': hname => 'pm.pse.infra.camptocamp.org', ensure => absent }
      vz::ve { '102': hname => 'lists.pse.infra.camptocamp.org', ensure => absent }
      vz::ve { '103': hname => 'dev.pse.infra.camptocamp.org', ensure => absent }
      vz::ve { '125': hname => 'pkg.pse.infra.camptocamp.org', ensure => absent }
      vz::ve { '126': hname => 'monit.pse.infra.camptocamp.org' }
      vz::ve { '140': hname => 'content-factory.pse.infra.camptocamp.org', ensure => absent }
      vz::ve { '141': hname => 'pre-prod.pse.infra.camptocamp.org', ensure => absent }

    }

    'hn5': {

      lxc::container { 'rproxy.pse.infra.camptocamp.org':
        ctid   => 60,
        suite  => 'wheezy',
        fssize => '35G',
      }

      lxc::container { 'memcache1.pse.infra.camptocamp.org':
        ctid   => 66,
        suite  => 'wheezy',
        fssize => '2G',
      }

      lxc::container { 'lists.pse.infra.camptocamp.org':
        ctid   => 102,
        suite  => 'squeeze',
        fssize => '3G',
      }

      lxc::container { 'dnscache.pse.infra.camptocamp.org':
        ctid   => 50,
        suite  => 'wheezy',
        fssize => '2G',
      }

      lxc::container { 'msgbroker.pse.infra.camptocamp.org':
        ctid   => 55,
        suite  => 'wheezy',
        fssize => '2G',
      }

      lxc::container { 'pkg.pse.infra.camptocamp.org':
        ctid   => 125,
        suite  => 'wheezy',
        fssize => '3G',
      }

      lxc::container { 'pm.pse.infra.camptocamp.org':
        ctid   => 101,
        suite  => 'squeeze',
        fssize => '6G',
      }

      lxc::container { 'dev.pse.infra.camptocamp.org':
        ctid   => 103,
        suite  => 'squeeze',
        fssize => '5G',
      }

      lxc::container { 'content-factory.pse.infra.camptocamp.org':
        ctid   => 140,
        suite  => 'squeeze',
        fssize => '10G',
      }

      lxc::container { 'pre-prod.pse.infra.camptocamp.org':
        ctid   => 141,
        suite  => 'squeeze',
        fssize => '12G',
      }

    }

    'hn6': {

      lxc::container { 'stats.pse.infra.camptocamp.org':
        ctid   => 75,
        suite  => 'wheezy',
        fssize => '3G',
      }

      lxc::container { 'memcache0.pse.infra.camptocamp.org':
        ctid   => 65,
        suite  => 'wheezy',
        fssize => '2G',
      }

      lxc::container { 'collectd0.pse.infra.camptocamp.org':
        ctid   => 127,
        suite  => 'wheezy',
        fssize => '80G',
      }

      lxc::container { 'test-stef74.pse.infra.camptocamp.org':
        ctid   => 204,
        suite  => 'wheezy',
        fssize => '3G',
      }

    }
  }
}
