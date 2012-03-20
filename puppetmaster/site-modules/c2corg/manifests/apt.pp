class c2corg::apt {

  $debmirror = $datacenter ? {
    /c2corg|epnet|pse/ => 'http://mirror.switch.ch/ftp/mirror',
    'gandi'        => 'http://mirrors.gandi.net',
    default        => 'http://cdn.debian.net',
  }

  include apt::unattended-upgrade::automatic

  apt::sources_list { "debian":
    content => inline_template("# file managed by puppet
<% if operatingsystem != 'GNU/kFreeBSD' -%>
deb <%= debmirror %>/debian/ lenny main contrib non-free
deb http://security.debian.org/ lenny/updates main contrib non-free
deb <%= debmirror %>/debian/ lenny-proposed-updates main contrib non-free
<% end -%>

deb <%= debmirror %>/debian/ squeeze main contrib non-free
deb http://security.debian.org/ squeeze/updates main contrib non-free
deb <%= debmirror %>/debian/ squeeze-proposed-updates main contrib non-free

deb <%= debmirror %>/debian/ wheezy main contrib non-free
deb http://security.debian.org/ wheezy/updates main contrib non-free
deb <%= debmirror %>/debian/ wheezy-proposed-updates main contrib non-free

<% if lsbdistcodename != 'lenny' -%>
# sid disabled on Lenny because of bug debbug#400768
deb <%= debmirror %>/debian/ sid main contrib non-free
<% end -%>
"),
  }

  apt::sources_list { "c2corg":
    content => "# file managed by puppet
deb http://pkg.dev.camptocamp.org/c2corg/ $lsbdistcodename main
",
  }

  if ($lsbdistcodename != 'wheezy') { # no backports available for wheezy yet
    apt::sources_list { "debian-backports":
      content => "# file managed by puppet
deb http://backports.debian.org/debian-backports ${lsbdistcodename}-backports main contrib non-free
",
    }
  }

  apt::key { "c2corg":
    source => "http://pkg.dev.camptocamp.org/pubkey.txt",
  }

  apt::preferences { "lenny":
    package  => "*",
    pin      => "release n=lenny",
    priority => undef,
  }

  apt::preferences { "lenny-proposed-updates":
    package  => "*",
    pin      => "release n=lenny-proposed-updates",
    priority => undef,
  }

  apt::preferences { "squeeze":
    package  => "*",
    pin      => "release n=squeeze",
    priority => undef,
  }

  apt::preferences { "squeeze-proposed-updates":
    package  => "*",
    pin      => "release n=squeeze-proposed-updates",
    priority => undef,
  }

  apt::preferences { "wheezy":
    package  => "*",
    pin      => "release n=wheezy",
    priority => undef,
  }

  apt::preferences { "wheezy-proposed-updates":
    package  => "*",
    pin      => "release n=wheezy-proposed-updates",
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
