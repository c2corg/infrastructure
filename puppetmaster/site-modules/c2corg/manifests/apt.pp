class c2corg::apt {

  include apt::unattended-upgrade::automatic

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

<% if lsbdistcodename != 'lenny' -%>
# sid disabled on Lenny because of bug debbug#400768
deb http://mirror.switch.ch/ftp/mirror/debian/ sid main contrib non-free
<% end -%>
"),
  }

  $pkgrepo = $ipaddress ? {
    /192\.168\.19.*/ => '192.168.191.125',
    '128.179.66.13'  => '192.168.191.125',
    default          => '128.179.66.13:8083',
  }


  apt::sources_list { "c2corg":
    content => "# file managed by puppet
deb http://$pkgrepo/test/ $lsbdistcodename main
deb http://$pkgrepo/prod/ $lsbdistcodename main
",
  }

  apt::key { "c2corg":
    source => "http://$pkgrepo/pubkey.txt",
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

  apt::preferences { "c2corg":
    package  => "*",
    pin      => "release l=C2corg, a=${lsbdistcodename}",
    priority => "110",
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

}

class c2corg::apt::lenny inherits c2corg::apt {

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

class c2corg::apt::squeeze inherits c2corg::apt {

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
