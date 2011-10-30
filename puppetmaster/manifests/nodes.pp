# common template
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
  include c2corg::sudo # TODO: only if package sudo is installed

}

# VM - configuration management
node 'pm' inherits 'base-node' {

  include puppet::server
  include c2corg::collectd::client

  # TODO: mv this stuff to a decent backend system
  file { "/etc/c2corg":
    ensure => directory,
    owner  => "marc",
  }

  c2corg::backup::dir {
    ["/srv/puppetmaster", "/var/lib/puppet/ssl", "/home", "/etc/c2corg"]:
  }

  realize C2corg::Account::User[marc]
}

# VM - mailinglists
node 'lists' inherits 'base-node' {

  #TODO: graph/monitor postfix & sympa
  #TODO: SPF headers
  #TODO: script meteofrance

  include c2corg::mailinglists
  include c2corg::collectd::client

}

# VM - package repository
node 'pkg' inherits 'base-node' {

  include c2corg::reprepro

  c2corg::backup::dir { "/srv/deb-repo/": }

}

# VM - misc dev/private ressources
node 'dev' inherits 'base-node' {

  include c2corg::trac
  include c2corg::wikiassoce

  include c2corg::devproxy::http
  include c2corg::devproxy::https

  c2corg::backup::dir { [
    "/srv/trac",
    "/srv/svn",
    "/var/lib/dokuwiki/",
  ]: }

}

# VM - logs, stats and graphs
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

# xen VM hosted at gandi.net (95.142.173.157) - backup & IPv6 gateway
node 'backup' inherits 'base-node' {

  include c2corg::backup::server
  include c2corg::webserver::ipv6gw

}

# ProLiant DL360 G4p - main router + virtualisation
node 'hn0' inherits 'base-node' {

  include c2corg::hn::hn0

  include vz
  include c2corg::vz

  include c2corg::collectd::client
  # c2corg::backup::dir { "/var/lib/vz/template/cache/": }
}

# ProLiant DL360 G4 - varnish
node 'hn1' inherits 'base-node' {

  include c2corg::hn::hn1

  include c2corg::varnish::instance

  include c2corg::collectd::client
}

# PowerEdge 2950 - legacy webserver + haproxy
node 'hn2' inherits 'base-node' {

  include c2corg::hn::hn2

  c2corg::backup::dir { [
    "/srv/chroot-c2corg/var/www/camptocamp.org/web/uploads/",
    "/srv/chroot-c2corg/var/www/camptocamp.org/web/forums/img/avatars/",
    "/srv/chroot-c2corg/var/www/camptocamp.org/web/stats/",
  ]: }

  include haproxy
  include haproxy::collectd

  include c2corg::collectd::client
  include apache::collectd

  collectd::plugin { "processes":
    content => '# Avoid LoadPlugin as processes is already loaded elsewhere
<Plugin processes>
  Process "apache2"
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

  # preventive workaround, while trac#745 isn't properly fixed
  host { "meta.camptocamp.org": ip => "127.0.0.2" }

}

# X3550 M3 - prod webserver
node 'hn3' inherits 'base-node' {

  realize C2corg::Account::User[alex]
  realize C2corg::Account::User[marc]
  realize C2corg::Account::User[xbrrr]
  realize C2corg::Account::User[gottferdom]
  realize C2corg::Account::User[gerbaux]

  realize C2corg::Account::User[c2corg]

  include c2corg::hn::hn3

  include c2corg::webserver::symfony
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::prod
  include c2corg::xcache

  include c2corg::prod::filesystems::symfony
  include c2corg::prodenv::symfony

  include c2corg::collectd::client

  #TODO: backups
}

# X3550 M3 - prod database
node 'hn4' inherits 'base-node' {

  include c2corg::hn::hn4

  include c2corg::database::prod
  include c2corg::prod::filesystems::postgres
  include c2corg::prodenv::postgres

  include c2corg::collectd::client

  include postgresql::backup
  c2corg::backup::dir { "/var/backups/pgsql": }

}


# VM - pre-prod database + webserver
node 'pre-prod' inherits 'base-node' {

  realize C2corg::Account::User[alex]
  realize C2corg::Account::User[marc]
  realize C2corg::Account::User[xbrrr]
  realize C2corg::Account::User[gottferdom]
  realize C2corg::Account::User[gerbaux]

  realize C2corg::Account::User[c2corg]

  include c2corg::database::prod

  include c2corg::webserver::symfony
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::preprod
  include c2corg::xcache

  include c2corg::varnish::instance

  include c2corg::preprod::autoupdate

  include c2corg::collectd::client

}

# VM - content-factory database + webserver
node 'content-factory' inherits 'base-node' {

  include c2corg::database::dev

  include c2corg::webserver::symfony
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

  include postgresql::backup
  c2corg::backup::dir { "/var/backups/pgsql": }

  apache::auth::htpasswd { "c2corg@camptocamp.org":
    vhost    => "camptocamp.org",
    username => "c2corg",
    cryptPassword => "UxYkCOe3sNVJc",
  }

  apache::auth::basic::file::user { "require password for website access":
    location => "/",
    vhost    => "camptocamp.org",
  }

  include c2corg::collectd::client

}

# VM
node 'test-marc' inherits 'base-node' {

}

# VM
node 'test-alex' inherits 'base-node' {

  realize C2corg::Account::User[alex]
  c2corg::account::user { "alex@root": user => "alex", account => "root" }

  include c2corg::database::dev

  include c2corg::webserver::symfony
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

}

# VM
node 'test-xbrrr' inherits 'base-node' {

  realize C2corg::Account::User[xbrrr]
  c2corg::account::user { "xbrrr@root": user => "xbrrr", account => "root" }

  include c2corg::database::dev

  include c2corg::webserver::symfony
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

}
