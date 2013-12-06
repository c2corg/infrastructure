class c2cinfra::common::packages {

  include gnupg

  package { [
    "ack-grep", "arping", "at", "atop",
    "bash-completion", "bc", "bind9-host", "bsdmainutils", "bzr",
    "curl", "cron", "cvs",
    "dc", "dnsutils",
    "elinks", "emacs23-nox", "ethtool",
    "fping", "ftp",
    "git-core", "git-svn",
    "htop",
    "iputils-ping", "iotop", "iptraf", "iso-codes",
    "less", "locales-all", "logrotate", "lsb-release", "lsof",
    "man-db", "m4", "make", "mosh", "mtr-tiny",
    "netcat", "ngrep", "nmap", "ntp",
    "patch", "psmisc", "pv", "pwgen",
    "rsync",
    "screen", "socat", "strace", "sudo", "subversion", "subversion-tools", "sysstat",
    "tcpdump", "telnet", "time", "tmux", "traceroute", "tshark",
    "unzip",
    "vim", "vlan",
    "whois", "wget",
    "xauth", "xfsprogs",
    ]: ensure => installed
  }

  case $::lsbdistcodename {
    'squeeze': {
      apt::pin { 'misc_pkgs_from_bpo':
        packages => 'mosh',
        release  => "${::lsbdistcodename}-backports",
        priority => '1010',
      }

    }
  }

}
