class c2corg::apacheconf::prod inherits c2corg::apacheconf {

  include c2corg::apacheconf::redirections
  include apache::collectd

  include c2corg::prod::apache::disable80

  # don't listen on *:80, This is haproxy's job.
  apache::listen { "${symfony_master_host}:80": ensure => present } # TODO: this is crap
  apache::listen { "127.0.0.1:80": ensure => present } # needed by collectd

  if ($::hostname !~ /failover/) {

    # TODO: deduplicate this
    host { "storage-backend.c2corg":
      ip => '192.168.192.70',
    }

    apache::directive { "photo store proxy":
      vhost     => "camptocamp.org",
      directive => "
RewriteCond %{REQUEST_URI} ^/uploads/images.*
RewriteCond /srv/www/camptocamp.org/web/%{REQUEST_URI} !-f
RewriteRule ^/(.*) http://storage-backend.c2corg/\$1 [P,L]
",
    }

    xcache::param {
      "xcache/xcache.size":  value => "128M";
      "xcache/xcache.count": value => "12";
    }
  }

}
