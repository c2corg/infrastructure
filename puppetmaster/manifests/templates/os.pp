class os {

  apt::sources_list { "debian":
    content => "# file managed by puppet
deb http://mirror.switch.ch/ftp/mirror/debian/ lenny main contrib non-free
deb http://mirror.switch.ch/ftp/mirror/debian-security/ lenny/updates main contrib non-free
deb http://volatile.debian.org/debian-volatile lenny/volatile main
",
  }

  apt::sources_list{ "backports.org":
    content => "# file managed by puppet
deb http://www.backports.org/debian lenny-backports main contrib non-free
",
  }

  apt::key { "16BA136C":
    source => "http://backports.org/debian/archive.key",
  }

  file { "/etc/apt/sources.list":
    content => "# file managed by puppet\n",
    before => Exec["apt-get_update"],
    notify => Exec["apt-get_update"],
  }


  apt::preferences { "lenny-backports":
    package => "*",
    pin   => "release a=${lsbdistcodename}-backports",
    priority => "400",
  }

  apt::preferences { "puppet-packages_from_bp.o":
     package  => "facter augeas-tools libaugeas0 augeas-lenses puppet puppetmaster",
     pin      => "release a=${lsbdistcodename}-backports",
     priority => "1010",
  }

  package { [
    "bash-completion",
    "curl", "cvs",
    "dnsutils",
    "elinks", "ethtool",
    "git-core", "git-svn", "gnupg",
    "iotop", "iptraf",
    "less", "lsof",
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

}
