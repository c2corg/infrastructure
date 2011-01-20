class c2corg::varnish::instance {

  include varnish

  Varnish::Instance {
    vcl_file   => "puppet:///c2corg/ha/c2corg.vcl",
    varnishlog => false,
  }

  case $hostname {
    hn1: {

      host { "symfony-backend.c2corg":
        ip => '192.168.192.3',
      }

      varnish::instance { $hostname:
        storage => "malloc,7400M",
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

  #TODO: collectd

}
