class c2corg::mcollective::client {

  include c2corg::mcollective
  include c2corg::password

  package { "mcollective-client":
    ensure  => present,
    require => Package["ruby-stomp"],
    before  => File["/etc/mcollective/client.cfg"],
  }

  package { [
    'mcollective-filemgr-client',
    'mcollective-package-client',
    'mcollective-puppetd-client',
    'mcollective-service-client',
    ]: ensure => present,
  }

  file { "/etc/mcollective/client.cfg":
    mode    => 0644,
    require => Package["mcollective-client"],
    content => "# file managed by puppet
topicprefix = /topic/
main_collective = mcollective
collectives = mcollective
libdir = /usr/share/mcollective/plugins
logger_type = syslog
logfile = /dev/null
loglevel = info

# Plugins
securityprovider = psk
plugin.psk = ${c2corg::password::mco_psk}

connector = stomp
plugin.stomp.host = ${c2corg::mcollective::broker}
plugin.stomp.port = 61613
plugin.stomp.user = ${c2corg::password::mco_user}
plugin.stomp.password = ${c2corg::password::mco_pass}
",
  }

}
