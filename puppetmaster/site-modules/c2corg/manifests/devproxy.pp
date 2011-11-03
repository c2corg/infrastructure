class c2corg::devproxy::http {

  c2corg::devproxy::proxy { "pkg.dev.camptocamp.org":
    host => "pkg.psea.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "content-factory.dev.camptocamp.org":
    host => "content-factory.psea.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "pre-prod.dev.camptocamp.org":
    host => "pre-prod.psea.infra.camptocamp.org:8080",
    aliases => [
      "s.pre-prod.dev.camptocamp.org",
      "m.pre-prod.dev.camptocamp.org",
      "www.pre-prod.dev.camptocamp.org",
      "meta.pre-prod.dev.camptocamp.org",
    ],
  }

  c2corg::devproxy::proxy { "test-xbrrr.dev.camptocamp.org":
    host => "test-xbrrr.psea.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "test-alex.dev.camptocamp.org":
    host => "test-alex.psea.infra.camptocamp.org",
  }

  c2corg::devproxy::proxy { "test-marc.dev.camptocamp.org":
    host => "test-marc.psea.infra.camptocamp.org",
  }

}

class c2corg::devproxy::https {

  Apache::Proxypass {
    notify => Exec["make dashboard.html"],
  }

  /* required for ddraw.cgi */
  package { "libapache2-mod-proxy-html": }

  apache::module { "proxy_html":
    ensure  => present,
    require => Package["libapache2-mod-proxy-html"]
  }

  apache::proxypass { "pgfouine reports":
    location => "/dashboard/pgfouine/",
    url      => "http://monit.psea.infra.camptocamp.org/pgfouine/",
    vhost    => "dev.camptocamp.org",
  }

  apache::proxypass { "haproxy logs":
    location => "/dashboard/haproxy-logs/",
    url      => "http://monit.psea.infra.camptocamp.org/haproxy-logs/",
    vhost    => "dev.camptocamp.org",
  }

  apache::proxypass { "haproxy stats":
    location => "/dashboard/haproxy-stats",
    url      => "http://hn3.psea.infra.camptocamp.org:8008/stats",
    vhost    => "dev.camptocamp.org",
  }

  apache::proxypass { "apache server-status":
    location => "/dashboard/hn3-apache-server-status",
    url      => "http://hn3.psea.infra.camptocamp.org/server-status",
    vhost    => "dev.camptocamp.org",
  }

  apache::proxypass { "drraw rrd viewer":
    location => "/dashboard/drraw.cgi",
    url      => "http://monit.psea.infra.camptocamp.org/cgi-bin/drraw.cgi",
    vhost    => "dev.camptocamp.org",
  }

  exec { "make dashboard.html":
    command     => 'egrep -hi "proxypass\s+" *.conf | awk \' { printf "<li><a href=%s>%s</a></li>\n", $2, $2 } \' > ../private/dashboard.html',
    cwd         => "/var/www/dev.camptocamp.org/conf/",
    refreshonly => true,
    require     => Apache::Vhost-ssl["dev.camptocamp.org"],
  }

  apache::directive { "dashboard alias":
    vhost     => "dev.camptocamp.org",
    directive => "Alias /dashboard /var/www/dev.camptocamp.org/private/dashboard.html",
  }

  apache::directive { "rewrite drraws hardcoded URLs":
    vhost     => "dev.camptocamp.org",
    directive => "
<Location /dashboard/drraw.cgi>
  SetOutputFilter proxy-html
  ProxyHTMLURLMap http://monit.psea.infra.camptocamp.org/cgi-bin/drraw.cgi /dashboard/drraw.cgi
</Location>
",
    require   => Apache::Module["proxy_html"],
  }

  apache::directive { "rewrite haproxy hardcoded URLs":
    vhost     => "dev.camptocamp.org",
    directive => "
<Location /dashboard/haproxy-logs/>
  SetOutputFilter proxy-html
  ProxyHTMLURLMap /haproxy-logs/ /dashboard/haproxy-logs/
</Location>
",
    require   => Apache::Module["proxy_html"],
  }

  apache::directive { "rewrite pgfouine hardcoded URLs":
    vhost     => "dev.camptocamp.org",
    directive => "
<Location /dashboard/pgfouine/>
  SetOutputFilter proxy-html
  ProxyHTMLURLMap /pgfouine/ /dashboard/pgfouine/
</Location>
",
    require   => Apache::Module["proxy_html"],
  }

  apache::auth::basic::file::user { "require password for dashboard access":
    location => "/dashboard",
    vhost    => "dev.camptocamp.org",
    authUserFile => "/srv/trac/projects/c2corg/conf/htpasswd",
  }

}


define c2corg::devproxy::proxy($ensure='present', $host='', $aliases=[]) {

  apache::vhost { $name:
    aliases => $aliases,
    ensure  => $ensure
  } 

  apache::directive { "set ProxyPreserveHost for $name":
    ensure    => $ensure,
    vhost     => $name,
    directive => "ProxyPreserveHost on",
  }

  apache::proxypass { "set ProxyPass for $name":
    ensure    => $ensure,
    location  => "/",
    url       => "http://${host}/",
    vhost     => $name,
  }

}
