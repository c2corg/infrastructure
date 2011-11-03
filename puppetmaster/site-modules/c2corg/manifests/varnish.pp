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
        storage => "malloc,64G", # malloc on a huge swap partition
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
        address      => ["*:8080"],
        storage_size => "512M",
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

class c2corg::varnish::typesdb {

  $typesdb = "/usr/share/collectd/varnish.db"

  collectd::plugin { "varnish-typesdb":
    content => "TypesDB \"${typesdb}\"\n",
  }

  file { "varnish collectd types":
    path    => $typesdb,
    content => "# file managed by puppet
#bytes     value:GAUGE:0:U
cache_operation   value:DERIVE:0:U
#cache_result    value:DERIVE:0:U
#connections   value:DERIVE:0:U
#http_requests   value:DERIVE:0:U
requests    value:GAUGE:0:U
#threads     value:GAUGE:0:U
#total_bytes   value:DERIVE:0:U
total_operations  value:DERIVE:0:U
#total_requests    value:DERIVE:0:U
total_sessions    value:DERIVE:0:U
total_threads   value:DERIVE:0:U
",
    notify => Service["collectd"],
  }

}
