class docker::logging {

  $logging_target = hiera('logging_target')
  $logging_token  = hiera('logging_token')

  apt::pin { 'rsyslog_from_bpo':
    packages => 'rsyslog rsyslog-relp',
    release  => "${::lsbdistcodename}-backports",
    priority => '1010',
  } ->
  package { 'rsyslog-relp':
    ensure => present,
  } ->

  file { '/etc/rsyslog.d/docker-remotelogs.conf':
    ensure  => present,
    notify  => Service['syslog'],
    content => template('docker/docker-remotelogs.conf.erb'),
  }

  file_line { 'rsyslog: disable imuxsock':
    path   => "/etc/rsyslog.conf",
    match  => '(module.+load|\$ModLoad).+imuxsock.*',
    line   => '# module(load="imuxsock") # disabled',
    notify => Service['syslog'],
  }

  file_line { 'rsyslog: disable imklog':
    path   => "/etc/rsyslog.conf",
    match  => '(module.+load|\$ModLoad).+imklog.*',
    line   => '# module(load="imklog") # disabled',
    notify => Service['syslog'],
  }

  file_line { 'journald: disable syslog forwarding':
    path => '/etc/systemd/journald.conf',
    line => 'ForwardToSyslog=no',
  } ~>
  service { 'systemd-journald':
    enable => true,
    ensure => running,
  }

}
