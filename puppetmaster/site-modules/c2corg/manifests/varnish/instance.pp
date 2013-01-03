class c2corg::varnish::instance {

  include varnish

  Varnish::Instance {
    varnishlog => false,
  }

  $symfony_master_host   = hiera('symfony_master_host')
  $symfony_failover_host = hiera('symfony_failover_host')
  $c2cstats_host         = hiera('c2cstats_host')
  $metac2c_host          = hiera('metac2c_host')
  $metaskirando_host     = hiera('metaskirando_host')


  case $::hostname {
    hn1: {

      host { "symfony-backend.c2corg":
        ip => '192.168.192.4',
      }

      host { "storage-backend.c2corg":
        ip => '192.168.192.70',
      }

      varnish::instance { $::hostname:
        vcl_file  => 'puppet:///modules/c2corg/varnish/c2corg.vcl',
        storage   => ['malloc,64G'], # malloc on a huge swap partition
        corelimit => 'unlimited',
        params    => [ 'ban_lurker_sleep=3',
                       'ping_interval=6',
                       'thread_pool_min=15' ],
      }
    }

    rproxy: {
      varnish::instance { $::hostname:
        vcl_content => template('c2corg/varnish/c2corg.vcl.erb'),
        storage     => ["file,/var/lib/varnish/${::hostname}/varnish_storage.bin,32G"],
        params      => ['ban_lurker_sleep=3',
                        'ping_interval=6',
                        'thread_pool_min=15'],
      }
    }

    pre-prod: {
      varnish::instance { $::hostname:
        address     => ['*:8080'],
        vcl_content => template('c2corg/varnish/c2corg.vcl.erb'),
        storage     => ["file,/var/lib/varnish/${::hostname}/varnish_storage.bin,512M"],
      }
    }

    test-marc: {
      varnish::instance { $::hostname:
        vcl_content => template('c2corg/varnish/c2corg.vcl.erb'),
        storage     => ["file,/var/lib/varnish/${::hostname}/varnish_storage.bin,512M"],
      }

    }

  }

  # varnish plugin only backported for kFreeBSD instance
  if ($::operatingsystem == "GNU/kFreeBSD") {

    include c2corg::varnish::typesdb

    apt::preferences { "collectd_from_c2corg_repo":
      package  => "collectd collectd-core collectd-utils",
      pin      => "release l=C2corg, a=squeeze",
      priority => "1010",
    }

    collectd::plugin { "varnish":
      lines => [
        '<Instance>',
        'CollectCache       true',
        'CollectConnections true',
        'CollectBackend     true',
        'CollectSHM         true',
        'CollectESI         true',
        'CollectFetch       true',
        'CollectHCB         true',
        'CollectSMA         true',
        'CollectSMS         true',
        'CollectSM          true',
        'CollectTotals      true',
        'CollectWorkers     true',
        '</Instance>',
      ],
    }

  }

}
