class c2cinfra::common::packages {

  include gnupg

  package { [
    "ack-grep", "arping", "at", "atop",
    "bash-completion", "bc", "bind9-host", "bsdmainutils", "bzr",
    "curl", "cron", "cvs",
    "dc", "dnsutils",
    "elinks", "emacs23-nox",
    "fping", "ftp",
    "git-core", "git-svn",
    "htop",
    "iputils-ping", "iso-codes",
    "less", "locales-all", "logrotate", "lsb-release",
    "man-db", "m4", "make", "mosh", "mtr-tiny",
    "netcat", "nmap", "ntp",
    "patch", "psmisc", "pwgen",
    "rsync",
    "screen", "sudo", "subversion", "subversion-tools", "sysstat",
    "tcpdump", "telnet", "time", "tmux", "tshark",
    "unzip",
    "vim",
    "whois", "wget",
    "xauth",
    ]: ensure => installed
  }

  case $::operatingsystem {
    "Debian": {
      package { [
        "ethtool", "iotop", "iptraf", "lsof", "strace", "traceroute", "vlan",
        ]: ensure => installed
      }
    }
    "GNU/kFreeBSD": {
    }
  }

  case $::lsbdistcodename {
    "squeeze": {
      apt::preferences { "misc_pkgs_from_bpo":
        package  => "mosh",
        pin      => "release a=${::lsbdistcodename}-backports",
        priority => "1010",
      }

    }
  }

}
