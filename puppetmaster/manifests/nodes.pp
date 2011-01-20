node 'base-node' {

  include apt
  include puppet::client
  include c2corg::account
  include c2corg::mta
  include "c2corg::apt::$lsbdistcodename"
  include c2corg::common::packages
  include c2corg::common::services
  include c2corg::common::config
  include c2corg::syslog::client

}

node 'pm' inherits 'base-node' {

  include puppet::server
  include c2corg::collectd::client

  c2corg::backup::dir {
    ["/srv/puppetmaster", "/var/lib/puppet/ssl", "/home"]:
  }

  realize C2corg::Account::User[marc]
}

node 'lists' inherits 'base-node' {

}

node 'pkg' inherits 'base-node' {

  include c2corg::reprepro

  c2corg::backup::dir { "/srv/deb-repo/": }

}

node 'monit' inherits 'base-node' {

  include c2corg::collectd::server
  include c2corg::syslog::server
  include c2corg::syslog::pgfouine

  c2corg::backup::dir { ["/srv/collectd", "/srv/syslog"]: }

}

# ProLiant DL360 G4p - debian/squeeze
node 'hn0' inherits 'base-node' {

  include c2corg::hn::hn0

  include vz
  include c2corg::vz

  include c2corg::collectd::client
  # c2corg::backup::dir { "/var/lib/vz/template/cache/": }
}

# ProLiant DL360 G4 - debian/kFreeBSD
node 'hn1' inherits 'base-node' {

  include c2corg::hn::hn1

  include c2corg::varnish::instance

  include c2corg::collectd::client

  include puppet::devel
}

# PowerEdge 2950 - debian/lenny
node 'hn2' inherits 'base-node' {

  include c2corg::hn::hn2

  include haproxy

  include c2corg::collectd::client
  include apache::collectd

  collectd::plugin { "processes":
    content => '# Avoid LoadPlugin as processes is already loaded elsewhere
<Plugin processes>
  Process "apache2"
  Process "postgres"
</Plugin>
',
  }

  # Solution transitoire. Il faudrait trouver une solution qui s'intègre plus
  # intelligemment dans l'infra, peut-être au niveau de haproxy ou varnish.
  collectd::plugin { "httplogsc2corg":
    content => template("c2corg/collectd/httplogsc2corg.conf"), # argh, file() doesn't handle puppet:// URLs :-(
  }

}

node 'pre-prod' inherits 'base-node' {

  include c2corg::database::prod

  include c2corg::webserver::symfony
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::preprod

  include c2corg::varnish::instance

  augeas { "temporarily disable php-xcache admin auth":
    changes => "set /files/etc/php5/conf.d/xcache.ini/xcache.admin/xcache.admin.enable_auth Off",
  }

  /* hackish stuff to autotomatically install and update c2corg codebase */
  vcsrepo { "/srv/www/camptocamp.org/":
    ensure   => "present",
    revision => "HEAD",
    provider => "svn",
    source   => "http://dev.camptocamp.org/svn/c2corg/trunk/camptocamp.org/",
    notify   => Exec["c2corg refresh"],
  }

  file { ["/srv/www/camptocamp.org/cache", "/srv/www/camptocamp.org/log"]:
    ensure  => directory,
    owner   => "www-data",
    require => Vcsrepo["/srv/www/camptocamp.org/"],
  }

  file { "c2corg preprod.ini":
    path    => "/srv/www/camptocamp.org/deployment/preprod.ini",
    source  => "puppet:///c2corg/symfony/preprod.ini",
    require => Vcsrepo["/srv/www/camptocamp.org/"],
    notify  => [Exec["c2corg refresh"], Exec["c2corg install"]],
  }

  exec { "c2corg install":
    command => "php c2corg --install --conf preprod",
    cwd     => "/srv/www/camptocamp.org/",
    require => [File["/srv/www/camptocamp.org/cache"], File["/srv/www/camptocamp.org/log"]],
    logoutput   => true,
    refreshonly => true,
  }

  exec { "c2corg refresh":
    command => "php c2corg --refresh --conf preprod --build",
    cwd     => "/srv/www/camptocamp.org/",
    require => Exec["c2corg install"],
    logoutput   => true,
    refreshonly => true,
  }

  c2corg::account::user { "alex@root": user => "alex", account => "root" }
  c2corg::account::user { "gottferdom@root": user => "gottferdom", account => "root" }
  c2corg::account::user { "xbrrr@root": user => "xbrrr", account => "root" }
  c2corg::account::user { "gerbaux@root": user => "gerbaux", account => "root" }

  include c2corg::collectd::client

  package { "libapache2-mod-proxy-html": }

  apache::module { "proxy_html":
    ensure  => present,
    require => Package["libapache2-mod-proxy-html"]
  }

  apache::vhost { "admin-backends":
    aliases => ["128.179.66.13"],
  }

  apache::proxypass { "pgfouine reports":
    location => "/pgfouine",
    url      => "http://192.168.191.126/pgfouine",
    vhost    => "admin-backends",
  }

  apache::proxypass { "haproxy":
    location => "/haproxy",
    url      => "http://192.168.192.3:8008/stats",
    vhost    => "admin-backends",
  }

  apache::proxypass { "drraw rrd viewer":
    location => "/drraw.cgi",
    url      => "http://192.168.191.126/cgi-bin/drraw.cgi",
    vhost    => "admin-backends",
  }

  apache::directive { "rewrite drraws hardcoded URLs":
    vhost     => "admin-backends",
    directive => "
SetOutputFilter proxy-html
ProxyHTMLURLMap http://192.168.191.126/cgi-bin/drraw.cgi /drraw.cgi
",
    require   => Apache::Module["proxy_html"],
  }

  apache::auth::htpasswd { "c2corg@camptocamp.org":
    vhost    => "admin-backends",
    username => "c2corg",
    cryptPassword => "UxYkCOe3sNVJc",
  }

  apache::auth::basic::file::user { "protect logs stats and monitoring":
    vhost => "admin-backends",
  }

}

node 'test-marc' inherits 'base-node' {

}
