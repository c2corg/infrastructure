class c2corg::mcollective::node {

  include c2corg::mcollective
  include c2corg::password

  package { "mcollective":
    ensure  => present,
  }

  service { "mcollective":
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package["mcollective"],
  }

  file { "/etc/mcollective/server.cfg":
    ensure  => present,
    mode    => 0600,
    owner   => "root",
    require => Package["mcollective"],
    notify  => Service["mcollective"],
    content => "# file managed by puppet
topicprefix = /topic/
main_collective = mcollective
collectives = mcollective
libdir = /usr/share/mcollective/plugins
logger_type = syslog
logfile = /var/log/mcollective.log
loglevel = info
daemonize = 1

# Plugins
securityprovider = psk
plugin.psk = ${c2corg::password::mco_psk}

connector = stomp
plugin.stomp.host = ${c2corg::mcollective::broker}
plugin.stomp.port = 61613
plugin.stomp.user = ${c2corg::password::mco_user}
plugin.stomp.password = ${c2corg::password::mco_pass}

# Facts
factsource = yaml
plugin.yaml = /etc/mcollective/facts.yaml
",
  }

  file { "/etc/mcollective/facts.yaml":
    owner    => "root",
    group    => "root",
    mode     => 400,
    loglevel => debug,  # this is needed to avoid it being logged and reported on every run
    # avoid including highly-dynamic facts as they will cause unnecessary template writes
    content  => inline_template("<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime|timestamp|free)/ }.to_yaml %>"),
    require  => Package["mcollective"],
  }

}
