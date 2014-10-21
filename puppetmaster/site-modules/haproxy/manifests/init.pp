class haproxy {

  if $::lsbdistcodename == 'wheezy' {
    apt::pin { 'haproxy_from_bpo':
      packages => 'haproxy init-system-helpers',
      release  => "${::lsbdistcodename}-backports",
      priority => '1010',
    }
  }

  package { "haproxy":
    ensure => present,
    before => File["/etc/haproxy/haproxy.cfg"],
  }

  service { "haproxy":
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => "/etc/init.d/haproxy reload",
    require   => Package["haproxy"],
  }

  etcdefault { 'start haproxy at boot':
    key    => 'ENABLED',
    file   => 'haproxy',
    value  => '1',
    notify => Service['haproxy'],
  }

  $varnish_host          = hiera('varnish_host')
  $symfony_master_host   = hiera('symfony_master_host')
  $symfony_failover_host = hiera('symfony_failover_host')

  file { "/etc/haproxy/haproxy.cfg":
    ensure  => present,
    owner   => "root",
    mode    => 0644,
    content => template("haproxy/haproxy.cfg.erb"),
    notify  => Service["haproxy"],
  }

  file { "/etc/rsyslog.d/zzz-haproxy.conf":
    ensure  => present,
    notify  => Service["syslog"],
    content => '# file managed by puppet

# enable local UDP syslog service, as haproxy runs chrooted
$ModLoad imudp
$UDPServerAddress 127.0.0.1
$UDPServerRun 514

# localy discard logs coming from haproxy
local1.* ~
',
  }

}
