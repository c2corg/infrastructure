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

  file { "/etc/c2corg":
    ensure => directory,
    owner  => "marc",
  }

  c2corg::backup::dir {
    ["/srv/puppetmaster", "/var/lib/puppet/ssl", "/home", "/etc/c2corg"]:
  }

  realize C2corg::Account::User[marc]
}

node 'lists' inherits 'base-node' {

}

node 'pkg' inherits 'base-node' {

  include c2corg::reprepro

  c2corg::backup::dir { "/srv/deb-repo/": }

}

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

# X3550 M3 - debian/squeeze
node 'hn3' inherits 'base-node' {

  include c2corg::hn::hn3

  include c2corg::collectd::client
}

# X3550 M3 - debian/squeeze
node 'hn4' inherits 'base-node' {

  include c2corg::hn::hn4

  Sysctl::Set_value { before => Service["postgresql"] }

  include c2corg::database::prod

  file { "/etc/postgresql/8.4/main/postgresql.conf":
    ensure => present,
    source => "puppet:///c2corg/pgsql/postgresql.conf.hn4",
    mode   => 0644,
    notify => Service["postgresql"],
  }

  sysctl::set_value {
    "kernel.shmmax": value => "4127514624";
    "kernel.shmall": value => "2097152";
  }

  mount { "/var/lib/postgresql/8.4/main":
    ensure  => mounted,
    atboot  => true,
    device  => "/dev/mapper/vg0-pgdata",
    fstype  => "ext3",
    options => "noatime",
  }

  mount { "/var/lib/postgresql/8.4/main/pg_xlog":
    ensure  => mounted,
    atboot  => true,
    device  => "/dev/mapper/vg0-pgxlog",
    fstype  => "xfs",
    options => "noatime,nobarrier",
    require => Mount["/var/lib/postgresql/8.4/main"],
    before  => Service["postgresql"],
  }

  include c2corg::collectd::client

  include postgresql::backup
  c2corg::backup::dir { "/var/backups/pgsql": }

  mount { "/var/backups/pgsql":
    ensure  => mounted,
    atboot  => true,
    device  => "/dev/mapper/vg0-pgbackup",
    fstype  => "ext3",
    options => "defaults",
  }

}


node 'pre-prod' inherits 'base-node' {

  include c2corg::database::prod

  include c2corg::webserver::symfony
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::preprod
  include c2corg::xcache

  include c2corg::varnish::instance

  include c2corg::preprod::autoupdate

  c2corg::account::user { "alex@root": user => "alex", account => "root" }
  c2corg::account::user { "gottferdom@root": user => "gottferdom", account => "root" }
  c2corg::account::user { "xbrrr@root": user => "xbrrr", account => "root" }
  c2corg::account::user { "gerbaux@root": user => "gerbaux", account => "root" }

  include c2corg::collectd::client

}

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

}
node 'test-xbrrr' inherits 'base-node' {

  realize C2corg::Account::User[xbrrr]
  c2corg::account::user { "xbrrr@root": user => "xbrrr", account => "root" }

  include c2corg::database::dev

  include c2corg::webserver::symfony
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

}
