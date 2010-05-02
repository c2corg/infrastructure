class os {

  include apt::unattended-upgrade::automatic

  apt::sources_list { "debian":
    content => "# file managed by puppet
deb http://mirror.switch.ch/ftp/mirror/debian/ ${lsbdistcodename} main contrib non-free
deb http://mirror.switch.ch/ftp/mirror/debian-security/ ${lsbdistcodename}/updates main contrib non-free

deb http://mirror.switch.ch/ftp/mirror/debian/ testing main contrib non-free

deb http://mirror.switch.ch/ftp/mirror/debian/ unstable main contrib non-free
",
  }

  apt::sources_list { "backports.org": content => "" }
  apt::sources_list { "debian-volatile": content => "" }

  apt::preferences { "testing":
    package => "*",
    pin   => "release a=testing",
    priority => "200",
  }

  apt::preferences { "unstable":
    package => "*",
    pin   => "release a=unstable",
    priority => "100",
  }

  package { "debian-archive-keyring":
    ensure => latest,
  }

  file { "/etc/apt/sources.list":
    content => "# file managed by puppet\n",
    before => Exec["apt-get_update"],
    notify => Exec["apt-get_update"],
  }

  file { "/etc/resolv.conf":
    content => "# file managed by puppet
search camptocamp.org
nameserver 8.8.8.8
nameserver 8.8.4.4
options rotate edns0
",
  }

  package { [
    "at",
    "bash-completion",
    "curl", "cron", "cvs",
    "dnsutils",
    "elinks", "ethtool",
    "git-core", "git-svn", "gnupg",
    "iotop", "iptraf",
    "less", "locales-all", "lsb-release", "lsof",
    "m4", "make", "mtr-tiny",
    "netcat", "nmap", "nscd", "ntp",
    "openssh-server",
    "patch", "pwgen",
    "rsyslog", "rsync",
    "screen", "strace", "subversion", "subversion-tools", "sysstat",
    "tcpdump", "telnet", "traceroute", "tshark",
    "unzip",
    "vim", "vlan",
    "wget"
    ]: ensure => installed
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

  # kernel must reboot if panic occurs
  sysctl::set_value { "kernel.panic":
    value => "60",
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

  Apt::Sources_list["backports.org"] {
    content => "# file managed by puppet
deb http://www.backports.org/debian ${lsbdistcodename}-backports main contrib non-free
",
  }

  Apt::Sources_list["debian-volatile"] {
    content => "# file managed by puppet
deb http://volatile.debian.org/debian-volatile ${lsbdistcodename}/volatile main
",
  }

  apt::preferences { "backports.org":
    package  => "*",
    pin      => "release a=${lsbdistcodename}-backports",
    priority => "400",
  }

  apt::preferences { "puppet-packages_from_bp.o":
     package  => "facter augeas-tools libaugeas0 augeas-lenses puppet puppetmaster",
     pin      => "release a=${lsbdistcodename}-backports",
     priority => "1010",
  }

}

class os::squeeze inherits os {

  Apt::Sources_list["backports.org"] { ensure => absent }
  Apt::Sources_list["debian-volatile"] { ensure => absent }

}
