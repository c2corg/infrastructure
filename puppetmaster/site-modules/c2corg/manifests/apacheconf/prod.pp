class c2corg::apacheconf::prod inherits c2corg::apacheconf {

  include c2corg::apacheconf::redirections

  collectd::config::plugin { 'apache collectd config':
    plugin   => 'apache',
    settings => '
<Instance "prod">
  URL "http://localhost/server-status?auto"
</Instance>
',
  }

  Apache::Vhost["camptocamp.org"] {
    accesslog_format => "%h %{X-Origin-IP}i %l %u %t \\\"%r\\\" %>s %b",
  }

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
