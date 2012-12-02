class c2cinfra::mcollective::client {

  include c2cinfra::mcollective

  $mco_psk  = hiera('mco_psk')
  $mco_user = hiera('mco_user')
  $mco_pass = hiera('mco_pass')

  package { "mcollective-client":
    ensure  => present,
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
plugin.psk = ${mco_psk}

connector = stomp
plugin.stomp.host = ${c2cinfra::mcollective::broker}
plugin.stomp.port = 61613
plugin.stomp.user = ${mco_user}
plugin.stomp.password = ${mco_pass}
",
  }

}
