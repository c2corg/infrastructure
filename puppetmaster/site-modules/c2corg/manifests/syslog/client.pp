class c2corg::syslog::client {

  $syslog_server = "192.168.192.126"

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

  if $datacenter =~ /c2corg|epnet|pse/ {
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

}
