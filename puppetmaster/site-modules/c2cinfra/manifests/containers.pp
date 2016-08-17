class c2cinfra::containers {

  Logical_volume {
    ensure       => present,
    volume_group => 'vg0',
  }

  case $::hostname {
    'hn0': {

    }

    'hn2': {

      lxc::container { 'www-failover.pse.infra.camptocamp.org':
        ctid   => 70,
        suite  => 'squeeze',
        fstype => 'ext3',
        fssize => '330G',
      }

      lxc::container { 'test-alex.pse.infra.camptocamp.org':
        ctid   => 201,
        suite  => 'squeeze',
        fssize => '18G',
      }

      lxc::container { 'test-xbrrr.pse.infra.camptocamp.org':
        ctid   => 202,
        suite  => 'squeeze',
        fssize => '15G',
      }

      lxc::container { 'test-marc.pse.infra.camptocamp.org':
        ctid   => 203,
        suite  => 'squeeze',
        fssize => '15G',
      }

      lxc::container { 'test-stef74.pse.infra.camptocamp.org':
        ctid   => 204,
        suite  => 'wheezy',
        fssize => '3G',
      }

      lxc::container { 'test-saimon.pse.infra.camptocamp.org':
        ctid   => 206,
        suite  => 'wheezy',
        fssize => '4G',
      }

      lxc::container { 'test-gottferdom.pse.infra.camptocamp.org':
        ctid   => 207,
        suite  => 'squeeze',
        fssize => '15G',
      }

      lxc::container { 'content-factory.pse.infra.camptocamp.org':
        ctid   => 140,
        suite  => 'squeeze',
        fssize => '12G',
      }

      lxc::container { 'pre-prod.pse.infra.camptocamp.org':
        ctid   => 141,
        suite  => 'wheezy',
        fssize => '15G',
      }

    }

    'hn3': {

      logical_volume { 'lxcdb0pgbackup': initial_size => '30G' } ->
      logical_volume { 'lxcdb0pgxlog':   initial_size => '5G' }  ->
      logical_volume { 'lxcdb0pgdata':   initial_size => '40G' } ->
      lxc::container { 'db0.pse.infra.camptocamp.org':
        ctid   => 52,
        suite  => 'wheezy',
        fssize => '5G',
        cap_drop => ['mac_admin','mac_override','sys_module'],
        extra_devices => ['b 254:2 rwm', 'b 254:3 rwm', 'b 254:4 rwm', 'b 254:6 rwm'],
      }

      @@mknod { 'pgbackup': type => 'b', major => 254, minor => 2, tag => 'db0' }
      @@mknod { 'pgxlog':   type => 'b', major => 254, minor => 3, tag => 'db0' }
      @@mknod { 'pgdata':   type => 'b', major => 254, minor => 4, tag => 'db0' }

    }

    'hn4': {

      logical_volume { 'lxcsymfony0srvwww':     initial_size => '2G' } ->
      logical_volume { 'lxcsymfony0varwww':     initial_size => '15G' } ->
      logical_volume { 'lxcsymfony0persistent': initial_size => '20G' }  ->
      logical_volume { 'lxcsymfony0volatile':   initial_size => '40G' } ->
      lxc::container { 'symfony0.pse.infra.camptocamp.org':
        ctid   => 62,
        suite  => 'wheezy',
        fssize => '5G',
        cap_drop => ['mac_admin','mac_override','sys_module'],
        extra_devices => ['b 254:2 rwm', 'b 254:3 rwm', 'b 254:4 rwm', 'b 254:5 rwm'],
      }

      @@mknod { 'srvwww':     type => 'b', major => 254, minor => 2, tag => 'symfony0' }
      @@mknod { 'varwww':     type => 'b', major => 254, minor => 3, tag => 'symfony0' }
      @@mknod { 'persistent': type => 'b', major => 254, minor => 4, tag => 'symfony0' }
      @@mknod { 'volatile':   type => 'b', major => 254, minor => 5, tag => 'symfony0' }

    }

    'hn5': {

      lxc::container { 'rproxy.pse.infra.camptocamp.org':
        ctid   => 60,
        suite  => 'wheezy',
        fssize => '38G',
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

      lxc::container { 'metrics.pse.infra.camptocamp.org':
        ctid   => 127,
        suite  => 'wheezy',
        fssize => '120G',
      }

    }

    'hn8': {

      lxc::container { 'riemann.pse.infra.camptocamp.org':
        ctid   => 128,
        suite  => 'wheezy',
        fssize => '3G',
      }

      lxc::container { 'solr.pse.infra.camptocamp.org':
        ctid   => 76,
        suite  => 'wheezy',
        fssize => '15G',
      }

      lxc::container { 'camo.pse.infra.camptocamp.org':
        ctid   => 83,
        suite  => 'wheezy',
        fssize => '2G',
      }

      lxc::container { 'pm.pse.infra.camptocamp.org':
        ctid   => 101,
        suite  => 'squeeze',
        fssize => '6G',
      }

      lxc::container { 'memcache1.pse.infra.camptocamp.org':
        ctid   => 66,
        suite  => 'wheezy',
        fssize => '2G',
      }

      lxc::container { 'dnscache.pse.infra.camptocamp.org':
        ctid   => 50,
        suite  => 'wheezy',
        fssize => '2G',
      }

      lxc::container { 'pkg.pse.infra.camptocamp.org':
        ctid   => 125,
        suite  => 'wheezy',
        fssize => '6G',
      }

      lxc::container { 'dev.pse.infra.camptocamp.org':
        ctid   => 103,
        suite  => 'wheezy',
        fssize => '10G',
      }

      lxc::container { 'lists.pse.infra.camptocamp.org':
        ctid   => 102,
        suite  => 'squeeze',
        fssize => '3G',
      }

      logical_volume { 'lxcdb1pgbackup': initial_size => '30G' } ->
      logical_volume { 'lxcdb1pgxlog':   initial_size => '5G' }  ->
      logical_volume { 'lxcdb1pgdata':   initial_size => '40G' } ->
      lxc::container { 'db1.pse.infra.camptocamp.org':
        ctid   => 53,
        suite  => 'wheezy',
        fssize => '5G',
        cap_drop => ['mac_admin','mac_override','sys_module'],
        extra_devices => ['b 254:4 rwm', 'b 254:5 rwm', 'b 254:6 rwm'],
      }

      @@mknod { 'pgbackup': type => 'b', major => 254, minor => 4, tag => 'db1' }
      @@mknod { 'pgxlog':   type => 'b', major => 254, minor => 5, tag => 'db1' }
      @@mknod { 'pgdata':   type => 'b', major => 254, minor => 6, tag => 'db1' }

    }
  }
}
