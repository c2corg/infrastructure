# common template
node 'base-node' {

  include apt
  include openssl
  include puppet::client
  include c2corg::account
  include c2corg::mta
  include c2corg::ssh::sshd
  include "c2corg::apt::$lsbdistcodename"
  include c2corg::common::packages
  include c2corg::common::services
  include c2corg::common::config
  include c2corg::hosts
  include c2corg::syslog::client
  include c2corg::sudo # TODO: only if package sudo is installed

  # Marc doesn't need to use root's account every time he must
  # manually run puppet.
  realize C2corg::Account::User['marc']

  # TODO: install mcollective
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

}

# VM - RFC1918 subnet DNS cache
node 'dnscache' inherits 'base-node' {
  include unbound
}

# VM - mailinglists
node 'lists' inherits 'base-node' {

  #TODO: graph/monitor postfix & sympa
  #TODO: SPF headers

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

  # TODO:
  # - fix broken carbon init script (restart/status)

  include c2corg::collectd::server
  include graphite::carbon
  include graphite::collectd
  include graphite::webapp
  include c2corg::syslog::server
  include c2corg::syslog::pgfouine
  include c2corg::syslog::haproxy

  $mpm_package = 'event'
  include apache

  apache::vhost { $fqdn: }

  c2corg::backup::dir { [
    "/var/lib/drraw",
    "/srv/carbon",
    "/var/www/",
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

  include c2corg::prod::fs::openvz

  include c2corg::collectd::client
  # c2corg::backup::dir { "/var/lib/vz/template/cache/": }
}

# ProLiant DL360 G4 - varnish
node 'hn1' inherits 'base-node' {

  include c2corg::hn::hn1

  include c2corg::varnish::instance

  include c2corg::collectd::client
}

# PowerEdge 2950 - virtualisation
node 'hn2' inherits 'base-node' {

  include c2corg::hn::hn2

  include vz
  include c2corg::vz

  include c2corg::prod::fs::openvz

  include c2corg::collectd::client

}

# X3550 M3 - prod webserver
node 'hn3' inherits 'base-node' {

  realize C2corg::Account::User['alex']
  realize C2corg::Account::User['xbrrr']
  realize C2corg::Account::User['gottferdom']
  realize C2corg::Account::User['gerbaux']

  $haproxy_vip_address = "128.179.66.23"
  $haproxy_varnish_address = "192.168.192.2"
  $haproxy_apache_address = "192.168.192.4"

  include c2corg::hn::hn3

  include c2corg::webserver::symfony::prod
  include c2corg::webserver::carto
  include c2corg::webserver::svg
  include c2corg::webserver::metaskirando

  include c2corg::apacheconf::prod
  include c2corg::xcache

  include c2corg::prod::fs::symfony
  include c2corg::prod::env::symfony
  include c2corg::prod::collectd::webserver

  include haproxy
  include haproxy::collectd

  include c2corg::collectd::client

  c2corg::backup::dir { "/srv/www/camptocamp.org/www-data/persistent": }

  # preventive workaround, while trac#745 isn't properly fixed
  #host { "meta.camptocamp.org": ip => "127.0.0.2" }

}

# X3550 M3 - prod database
node 'hn4' inherits 'base-node' {

  include c2corg::hn::hn4

  include c2corg::database::prod
  include c2corg::prod::fs::postgres
  include c2corg::prod::env::postgres

  include memcachedb
  include c2corg::prod::fs::memcachedb
  collectd::plugin { "memcached": lines => [] }

  include c2corg::collectd::client

  $postgresql_backupfmt = "custom"
  include postgresql::backup
  c2corg::backup::dir { "/var/backups/pgsql": }

}


# VM - pre-prod database + webserver
node 'pre-prod' inherits 'base-node' {

  realize C2corg::Account::User['alex']
  realize C2corg::Account::User['xbrrr']
  realize C2corg::Account::User['gottferdom']
  realize C2corg::Account::User['gerbaux']

  include c2corg::database::preprod

  include c2corg::webserver::symfony::preprod
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::preprod
  include c2corg::xcache

  include memcachedb

  include c2corg::varnish::instance

  include c2corg::collectd::client

}

# VM - content-factory database + webserver
node 'content-factory' inherits 'base-node' {

  include c2corg::database::dev

  include c2corg::webserver::symfony::content-factory
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::content-factory

  include postgresql::backup
  c2corg::backup::dir { "/var/backups/pgsql": }

  include c2corg::collectd::client

}

# VM
node 'test-marc' inherits 'base-node' {

}

# VM
node 'test-alex' inherits 'base-node' {

  $developer = "alex"

  realize C2corg::Account::User['alex']
  c2corg::account::user { "alex@root": user => "alex", account => "root" }

  include c2corg::database::dev

  include c2corg::webserver::symfony::dev
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

}

# VM
node 'test-xbrrr' inherits 'base-node' {

  $developer = "xbrrr"

  realize C2corg::Account::User['xbrrr']
  c2corg::account::user { "xbrrr@root": user => "xbrrr", account => "root" }

  include c2corg::database::dev

  include c2corg::webserver::symfony::dev
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

}

# VM
node 'test-jose' inherits 'base-node' {

  $developer = "jose"

  realize C2corg::Account::User['jose']
  c2corg::account::user { "jose@root": user => "jose", account => "root" }

  include c2corg::database::dev

  include c2corg::webserver::symfony::dev
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

}

# VM
node 'test-bubu' inherits 'base-node' {

  #$developer = "bubu"

  #realize C2corg::Account::User['bubu']
  #c2corg::account::user { "bubu@root": user => "bubu", account => "root" }

  #include c2corg::database::dev

  #include c2corg::webserver::symfony::dev
  #include c2corg::webserver::carto
  #include c2corg::webserver::svg

  #include c2corg::apacheconf::dev

}

# VM
node 'dev-cda' inherits 'base-node' {

  $developer = "easi"

  user { $developer:
    ensure     => present,
    shell      => "/bin/bash",
    managehome => true,
    groups     => ["adm", "www-data"],
  }

  c2corg::ssh::userkey { "Reynald Coupe on ${developer}":
    account => $developer,
    user    => "raynald.coupe@easi-services.fr",
    type    => "rsa",
    key     => "AAAAB3NzaC1yc2EAAAABIwAAAQEAzT/ARSQm1yf2KYkIlPZrDQsp+D1qX5uk7Qe196P2DMTMIEQ2kIVHA+c942MW/6PXQwYDdxyT541N9v0CnzIiACUimAg+j3ATeJD8vbiOj8XOkqYMAknLArhDU+6HjH/TG9FAlLOBr1w88POxOMg0YFyeRkkLn/16EwhmT9K8IQZJpmugFUK7WYn7KfWdPDF+i0B1J6aLawkSnrAmk3gCJIHG4wtiZ+nNn5L0LY09NOeSL7H3Ml4jcY8Dnph6ohWgPS6RCltFxSYqXQ6/ychXlFQS71pN/GAw2ArMt+fooVPtfhh6XcAi2MeF/ev/GqmfhxNVhJePIyVFugLLUl1qLw==",
  }

  include c2corg::database::dev

  include c2corg::webserver::symfony::easi
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

  c2corg::backup::dir {
    ["/srv/www/camptocamp.org/"]:
  }

}
