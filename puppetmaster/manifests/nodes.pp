node 'base-node' {

  include apt
  include puppet::client
  include c2corg::account
  include c2corg::mta
  include c2corg::sshd
  include "c2corg::apt::$lsbdistcodename"
  include c2corg::common::packages
  include c2corg::common::services
  include c2corg::common::config
  include c2corg::hosts
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
  include c2corg::syslog::haproxy

  c2corg::backup::dir { [
    "/var/lib/drraw",
    "/srv/collectd",
    "/var/www/pgfouine/",
    "/var/www/haproxy-logs/",
  ]: }

}

# xen VM hosted at gandi.net - 95.142.173.157
node 'backup' inherits 'base-node' {

  include c2corg::backup::server

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
}

# PowerEdge 2950 - debian/lenny
node 'hn2' inherits 'base-node' {

  include c2corg::hn::hn2

  c2corg::backup::dir { [
    "/srv/chroot-c2corg/var/www/camptocamp.org/web/uploads/",
    "/srv/chroot-c2corg/var/local/backup/pgsql/",
  ]: }

  include haproxy
  include haproxy::collectd

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

  # accès temporaire en attendant réinstallation machine.
  c2corg::account::user { "alex@root": user => "alex", account => "root" }

  # Solution transitoire. Il faudrait trouver une solution qui s'intègre plus
  # intelligemment dans l'infra, peut-être au niveau de haproxy ou varnish.
  collectd::plugin { "httplogsc2corg":
    source => "puppet:///c2corg/collectd/httplogsc2corg.conf",
  }

  # solution temporaire pour envoyer les stats postgresql vers collectd.
  collectd::plugin { "postgresql":
    content => "# file managed by puppet
LoadPlugin \"postgresql\"
<Plugin postgresql>
  <Database c2corg>
    Host \"/srv/chroot-c2corg/var/run/postgresql/\"
    Port \"5433\"
    User \"www-data\"
    Password \"www-data\"
  </Database>
</Plugin>
",
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
    notify  => Service["apache"],
    logoutput   => true,
    refreshonly => true,
  }

  c2corg::account::user { "alex@root": user => "alex", account => "root" }
  c2corg::account::user { "gottferdom@root": user => "gottferdom", account => "root" }
  c2corg::account::user { "xbrrr@root": user => "xbrrr", account => "root" }
  c2corg::account::user { "gerbaux@root": user => "gerbaux", account => "root" }

  include c2corg::collectd::client

  include c2corg::dashboard

}

node 'test-marc' inherits 'base-node' {

}

node 'test-alex' inherits 'base-node' {

  realize C2corg::Account::User[alex]
  c2corg::account::user { "alex@root": user => "alex", account => "root" }

  include c2corg::database::dev

  include c2corg::webserver::symfony
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

  augeas { "temporarily disable php-xcache admin auth":
    changes => "set /files/etc/php5/conf.d/xcache.ini/xcache.admin/xcache.admin.enable_auth Off",
  }

}
