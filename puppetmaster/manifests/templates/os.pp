class os {

  include apt::unattended-upgrade::automatic
  include gnupg

  apt::sources_list { "debian":
    content => inline_template("# file managed by puppet
<% if operatingsystem != 'GNU/kFreeBSD' -%>
deb http://mirror.switch.ch/ftp/mirror/debian/ lenny main contrib non-free
deb http://mirror.switch.ch/ftp/mirror/debian-security/ lenny/updates main contrib non-free
deb http://mirror.switch.ch/ftp/mirror/debian/ lenny-proposed-updates main contrib non-free
<% end -%>

deb http://mirror.switch.ch/ftp/mirror/debian/ squeeze main contrib non-free
deb http://mirror.switch.ch/ftp/mirror/debian-security/ squeeze/updates main contrib non-free
deb http://mirror.switch.ch/ftp/mirror/debian/ squeeze-proposed-updates main contrib non-free

deb http://mirror.switch.ch/ftp/mirror/debian/ sid main contrib non-free
"),
  }

  apt::preferences { "lenny":
    package  => "*",
    pin      => "release n=lenny",
    priority => undef,
  }

  apt::preferences { "squeeze":
    package  => "*",
    pin      => "release n=squeeze",
    priority => undef,
  }

  apt::preferences { "sid":
    package  => "*",
    pin      => "release n=sid",
    priority => "20",
  }

  apt::preferences { "snapshots":
    package  => "*",
    pin      => "origin snapshot.debian.org",
    priority => "10",
  }

  apt::preferences { "backports":
    package  => "*",
    pin      => "release a=${lsbdistcodename}-backports",
    priority => "50",
  }

  package { "debian-archive-keyring":
    ensure => latest,
  }

  apt::conf { "10apt-cache-limit":
    ensure  => present,
    content => 'APT::Cache-Limit 50000000;',
  }

  apt::conf { "01default-release":
    ensure  => present,
    content => undef,
  }


  file { "/etc/apt/sources.list":
    content => "# file managed by puppet\n",
    before => Exec["apt-get_update"],
    notify => Exec["apt-get_update"],
  }

  file { "/etc/resolv.conf":
    content => "# file managed by puppet
search c2corg
nameserver 8.8.8.8
nameserver 8.8.4.4
options rotate edns0
",
  }

  package { [
    "arping", "at",
    "bash-completion",
    "curl", "cron", "cvs",
    "dnsutils",
    "elinks",
    "git-core", "git-svn",
    "less", "locales-all", "lsb-release",
    "m4", "make", "mtr-tiny",
    "netcat", "nmap", "nscd", "ntp",
    "openssh-server",
    "patch", "pwgen",
    "rsyslog", "rsync",
    "screen", "subversion", "subversion-tools", "sysstat",
    "tcpdump", "telnet", "tshark",
    "unzip",
    "vim",
    "wget"
    ]: ensure => installed
  }

  case $operatingsystem {
    "Debian": {
      package { [
        "ethtool", "iotop", "iptraf", "lsof", "strace", "traceroute", "vlan",
        ]: ensure => installed
      }
    }
    "GNU/kFreeBSD": {
    }
  }

  /* Base services */
  service { "cron":
    ensure => running, enable => true,
    require => Package["cron"],
  }

  service { "atd":
    ensure => running, enable => true,
    require => Package["at"],
  }

  service { "rsyslog":
    ensure => running, enable => true, hasstatus => true,
    require => Package["rsyslog"],
  }

  service { "nscd":
    ensure => running, enable => true, hasstatus => true,
    require => Package["nscd"],
  }

  service { "ntp":
    ensure => running, enable => true, hasstatus => true,
    require => Package["ntp"],
  }

  service { "ssh":
    ensure => running, enable => true, hasstatus => true,
    require => Package["openssh-server"],
  }

  service { "sysstat":
    require => Package["sysstat"],
  }

  file { "/etc/timezone":
    content => "Europe/Zurich\n",
    notify  => Exec["configure timezone"],
  }

  exec { "configure timezone":
    command     => "dpkg-reconfigure --priority critical tzdata",
    refreshonly => true,
  }

  case $operatingsystem {
    "Debian": {
      if $is_virtual != true {
        # kernel must reboot if panic occurs
        sysctl::set_value { "kernel.panic": value => "60" }
        # disable tcp_sack due to Cisco bug in epnet routers
        sysctl::set_value { "net.ipv4.tcp_sack": value => "0" }
      }
    }
    "GNU/kFreeBSD": {
      # avoid sysctl type failure
      file { "/etc/sysctl.conf": ensure => present }
    }
  }

  augeas { "sysstat history":
    context => "/files/etc/default/sysstat",
    changes => ["set HISTORY 30", "set ENABLED true"],
    notify  => Service["sysstat"],
  }

  augeas { "disable ctrl-alt-delete":
    context => "/files/etc/inittab/*[action='ctrlaltdel']/",
    changes => [
      "set runlevels 12345",
      "set process '/bin/echo ctrlaltdel disabled'"
    ],
    notify  => Exec["refresh init"],
  }

  exec { "refresh init":
    refreshonly => true,
    command     => "kill -HUP 1",
  }

}

class os::lenny inherits os {

  Apt::Preferences["lenny"] {
    priority => "99",
  }

  Apt::Preferences["squeeze"] {
    priority => "50",
  }

  Apt::Conf["01default-release"] {
    content => 'APT::Default-Release "stable";', # warning: changing this can break the system !
  }

  apt::sources_list { "backports.org":
    content => "# file managed by puppet
deb http://www.backports.org/debian ${lsbdistcodename}-backports main contrib non-free
",
  }

  apt::sources_list { "debian-volatile":
    content => "# file managed by puppet
deb http://volatile.debian.org/debian-volatile ${lsbdistcodename}/volatile main
",
  }

  apt::preferences { "augeas_from_backports.org":
    package  => "augeas-tools libaugeas0 augeas-lenses libaugeas-ruby1.8",
    pin      => "release a=${lsbdistcodename}-backports",
    priority => "1010",
  }

  apt::preferences { "haproxy_from_backports.org":
    package  => "haproxy",
    pin      => "release a=${lsbdistcodename}-backports",
    priority => "1010",
  }

}

class os::squeeze inherits os {

  Apt::Preferences["lenny"] {
    priority => "50",
  }

  Apt::Preferences["squeeze"] {
    priority => "99",
  }

  Apt::Conf["01default-release"] {
    content => 'APT::Default-Release "testing";', # warning: changing this can break the system !
  }

}
