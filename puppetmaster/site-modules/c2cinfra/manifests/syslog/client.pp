class c2cinfra::syslog::client {

  $syslog_server = hiera('syslog_host')
  $logstash_server = hiera('logstash_host')

  package { "syslog":
    name   => "rsyslog",
    ensure => present,
  }

  service { "syslog":
    name    => "rsyslog",
    ensure  => running, enable => true, hasstatus => true,
    require => Package["syslog"],
  }

  file { "local syslog config":
    path    => "/etc/rsyslog.d/remotelogs.conf",
    ensure  => present,
    content => inline_template('# file managed by puppet
$SystemLogRateLimitInterval 0
$MaxMessageSize 64k
*.*    @@<%= syslog_server %>
*.*    @<%= logstash_server %>:5544;RSYSLOG_ForwardFormat
'),
    require => Package["syslog"],
    notify  => Service["syslog"],
  }

}
