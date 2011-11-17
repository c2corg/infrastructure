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
    url      => "http://monit.pse.infra.camptocamp.org/pgfouine/",
    vhost    => "dev.camptocamp.org",
  }

  apache::proxypass { "haproxy logs":
    location => "/dashboard/haproxy-logs/",
    url      => "http://monit.pse.infra.camptocamp.org/haproxy-logs/",
    vhost    => "dev.camptocamp.org",
  }

  apache::proxypass { "haproxy stats":
    location => "/dashboard/haproxy-stats",
    url      => "http://hn3.pse.infra.camptocamp.org:8008/stats",
    vhost    => "dev.camptocamp.org",
  }

  apache::proxypass { "apache server-status":
    location => "/dashboard/hn3-apache-server-status",
    url      => "http://hn3.pse.infra.camptocamp.org/server-status",
    vhost    => "dev.camptocamp.org",
  }

  apache::proxypass { "drraw rrd viewer":
    location => "/dashboard/drraw.cgi",
    url      => "http://monit.pse.infra.camptocamp.org/cgi-bin/drraw.cgi",
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
  ProxyHTMLURLMap http://monit.pse.infra.camptocamp.org/cgi-bin/drraw.cgi /dashboard/drraw.cgi
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
