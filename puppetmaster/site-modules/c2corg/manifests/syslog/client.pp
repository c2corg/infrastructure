class c2corg::syslog::client {

  $syslog_server = $datacenter ? {
    /c2corg|epnet|pse/ => "192.168.192.126",
    default            => "128.179.66.13",
  }

  if $lsbdistcodename == "lenny" {
    apt::preferences { "rsyslog_from_backports.org":
      package  => "rsyslog",
      pin      => "release a=${lsbdistcodename}-backports",
      priority => "1010",
    }
  }

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
<% if operatingsystem != "lenny" -%>
$MaxMessageSize 64k
<% end -%>
*.*    @@<%= syslog_server %>
'),
    require => Package["syslog"],
    notify  => Service["syslog"],
  }

}
