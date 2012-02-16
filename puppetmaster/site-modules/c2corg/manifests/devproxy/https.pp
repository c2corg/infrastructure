class c2corg::devproxy::https {

  c2corg::devproxy::dashboard { "pgfouine reports":
    location => "/pgfouine/",
    url      => "http://monit.pse.infra.camptocamp.org/pgfouine/",
    vhost    => "dev.camptocamp.org",
  }

  c2corg::devproxy::dashboard { "haproxy logs":
    location => "/haproxy-logs/",
    url      => "http://monit.pse.infra.camptocamp.org/haproxy-logs/",
    vhost    => "dev.camptocamp.org",
  }

  c2corg::devproxy::dashboard { "haproxy stats":
    location => "/haproxy-stats",
    url      => "http://hn3.pse.infra.camptocamp.org:8008/stats",
    vhost    => "dev.camptocamp.org",
  }

  c2corg::devproxy::dashboard { "apache server-status":
    location => "/hn3-apache-server-status",
    url      => "http://hn3.pse.infra.camptocamp.org/server-status",
    vhost    => "dev.camptocamp.org",
  }

  c2corg::devproxy::dashboard { "drraw rrd viewer":
    ensure   => absent,
    location => "/cgi-bin/drraw.cgi",
    url      => "http://monit.pse.infra.camptocamp.org/cgi-bin/drraw.cgi",
    vhost    => "drraw.dev.camptocamp.org",
  }

  c2corg::devproxy::dashboard { "graphite viewer":
    location => "/",
    url      => "http://monit.pse.infra.camptocamp.org:8080/",
    vhost    => "graphite.dev.camptocamp.org",
  }

  apache::module { "headers": ensure => present }

  apache::directive { "inject REMOTE_USER in headers":
    vhost     => "graphite.dev.camptocamp.org",
    require   => Apache::Module["headers"],
    directive => "
RewriteEngine On
RewriteRule .* - [E=PROXY_USER:%{LA-U:REMOTE_USER}]
RequestHeader set ProxyUser %{PROXY_USER}e
",
  }

  apache::directive { "dashboard alias":
    vhost     => "dev.camptocamp.org",
    directive => "Alias /dashboard /var/www/dev.camptocamp.org/private/dashboard.html"
  }

  file { "/var/www/dev.camptocamp.org/private/dashboard-AAA-header.part":
    content => "<html><body>\n",
    notify  => Exec["aggregate dashboard snippets"],
  }

  file { "/var/www/dev.camptocamp.org/private/dashboard-ZZZ-footer.part":
    content => "</body></html>\n",
    notify  => Exec["aggregate dashboard snippets"],
  }

  exec { "aggregate dashboard snippets":
    command     => "cat /var/www/dev.camptocamp.org/private/dashboard-* > /var/www/dev.camptocamp.org/private/dashboard.html",
    refreshonly => true,
  }

  # legacy stuff
  apache::directive { [
    "rewrite pgfouine hardcoded URLs",
    "rewrite graphite hardcoded URLs",
    "rewrite haproxy hardcoded URLs",
    "rewrite drraws hardcoded URLs",
  ]:
    vhost  => "dev.camptocamp.org",
    ensure => absent,
  }

  package { "libapache2-mod-proxy-html": ensure => absent }

  apache::module { "proxy_html":
    ensure  => absent,
  }

}
