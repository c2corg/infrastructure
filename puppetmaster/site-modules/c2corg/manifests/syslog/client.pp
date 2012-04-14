class c2corg::syslog::client {

  $syslog_server = hiera('syslog_host')

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
$MaxMessageSize 64k
*.*    @@<%= syslog_server %>
'),
    require => Package["syslog"],
    notify  => Service["syslog"],
  }

}
