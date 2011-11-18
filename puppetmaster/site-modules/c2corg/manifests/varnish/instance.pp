class c2corg::varnish::instance {

  include varnish

  Varnish::Instance {
    vcl_file   => "puppet:///c2corg/ha/c2corg.vcl",
    varnishlog => false,
  }

  case $hostname {
    hn1: {

      host { "symfony-backend.c2corg":
        ip => '192.168.192.4',
      }

      varnish::instance { $hostname:
        storage => ["malloc,64G"], # malloc on a huge swap partition
        corelimit => "unlimited",
        params  => [ "ban_lurker_sleep=3",
                     "ping_interval=6",
                     "thread_pool_min=15" ],
      }
    }

    pre-prod: {

      host { "symfony-backend.c2corg":
        ip => '127.0.0.1',
      }

      varnish::instance { $hostname:
        address => ["*:8080"],
        storage => ["file,/var/lib/varnish/${hostname}/varnish_storage.bin,512M"],
      }
    }
  }

  # varnish plugin only backported for kFreeBSD instance
  if ($operatingsystem == "GNU/kFreeBSD") {

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
