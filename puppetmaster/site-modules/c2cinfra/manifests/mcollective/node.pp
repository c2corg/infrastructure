class c2cinfra::mcollective::node {

  include c2cinfra::mcollective

  $mco_psk  = hiera('mco_psk')
  $mco_user = hiera('mco_user')
  $mco_pass = hiera('mco_pass')

  package { 'mcollective':
    ensure  => present,
  }

  etcdefault { 'enable mcollective at boot':
    file   => 'mcollective',
    key    => 'RUN',
    value  => 'yes',
    before => Service['mcollective'],
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
identity = ${::hostname}
daemonize = 1
classesfile = /var/lib/puppet/state/classes.txt

# Plugins
securityprovider = psk
plugin.psk = ${mco_psk}

connector = stomp
plugin.stomp.host = ${c2cinfra::mcollective::broker}
plugin.stomp.port = 61613
plugin.stomp.user = ${mco_user}
plugin.stomp.password = ${mco_pass}

# Facts
factsource = yaml
plugin.yaml = /etc/mcollective/facts.yaml

# Registration to keep rabbitmq awake
registerinterval = 300
registration = Agentlist
",
  }

  file { "/etc/mcollective/facts.yaml":
    owner    => "root",
    group    => "root",
    mode     => 400,
    loglevel => debug,  # this is needed to avoid it being logged and reported on every run
    # avoid including highly-dynamic facts as they will cause unnecessary template writes
    content  => inline_template("<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime|timestamp|free|mco_|path|environment)/ }.to_yaml %>"),
    require  => Package["mcollective"],
  }

}
