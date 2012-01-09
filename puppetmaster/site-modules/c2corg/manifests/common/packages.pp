class c2corg::common::packages {

  include gnupg

  package { [
    "arping", "at",
    "bash-completion", "bzr",
    "curl", "cron", "cvs",
    "dnsutils",
    "elinks",
    "emacs23-nox",
    "git-core", "git-svn",
    "htop",
    "less", "locales-all", "lsb-release",
    "m4", "make", "mtr-tiny",
    "netcat", "nmap", "ntp",
    "patch", "pwgen",
    "rsync",
    "screen", "sudo", "subversion", "subversion-tools", "sysstat",
    "tcpdump", "telnet", "time", "tshark",
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

  case $lsbdistcodename {
    "squeeze": {
      package { ["tmux"]: ensure => installed }
    }
  }

}
