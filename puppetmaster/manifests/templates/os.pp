class os {

  apt::sources_list { "debian":
    content => "# file managed by puppet
deb http://mirror.switch.ch/ftp/mirror/debian/ ${lsbdistcodename} main contrib non-free
deb http://mirror.switch.ch/ftp/mirror/debian-security/ ${lsbdistcodename}/updates main contrib non-free
",
  }

  apt::sources_list { "backports.org": content => "" }
  apt::sources_list { "debian-volatile": content => "" }

  apt::key { "16BA136C":
    source => "http://backports.org/debian/archive.key",
  }

  file { "/etc/apt/sources.list":
    content => "# file managed by puppet\n",
    before => Exec["apt-get_update"],
    notify => Exec["apt-get_update"],
  }

  package { [
    "bash-completion",
    "curl", "cvs",
    "dnsutils",
    "elinks", "ethtool",
    "git-core", "git-svn", "gnupg",
    "iotop", "iptraf",
    "less", "locales-all", "lsb-release", "lsof",
    "m4", "make", "mtr-tiny",
    "netcat", "nmap", "ntp",
    "patch", "pwgen",
    "rsync",
    "screen", "strace", "subversion", "subversion-tools", "sysstat",
    "tcpdump", "telnet", "traceroute", "tshark",
    "unzip",
    "vim", "vlan",
    "wget"
    ]: ensure => installed
  }

  # kernel must reboot if panic occurs
  sysctl::set_value { "kernel.panic":
    value => "60",
  }

  augeas { "sysstat history":
    context => "/files/etc/default/sysstat",
    changes => ["set HISTORY 30", "set ENABLED true"],
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
    package => "*",
    pin   => "release a=${lsbdistcodename}-backports",
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
