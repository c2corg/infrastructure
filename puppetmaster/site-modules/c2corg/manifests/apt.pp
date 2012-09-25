class c2corg::apt {

  $debmirror = $::datacenter ? {
    /c2corg|epnet|pse/ => 'http://mirror.switch.ch/ftp/mirror',
    'gandi'        => 'http://mirrors.gandi.net',
    default        => 'http://http.debian.net',
  }

  $pkgrepo = hiera('pkgrepo_host')

  apt::sources_list { "debian":
    content => inline_template("# file managed by puppet
deb <%= debmirror %>/debian/ squeeze main contrib non-free
deb http://security.debian.org/ squeeze/updates main contrib non-free
deb <%= debmirror %>/debian/ squeeze-proposed-updates main contrib non-free

<% if @operatingsystem != 'GNU/kFreeBSD' # fails to handle many sources lists -%>
deb <%= debmirror %>/debian/ wheezy main contrib non-free
deb http://security.debian.org/ wheezy/updates main contrib non-free
deb <%= debmirror %>/debian/ wheezy-proposed-updates main contrib non-free
<% end -%>
"),
  }

  apt::sources_list { "c2corg":
    content => "# file managed by puppet
deb http://${pkgrepo}/c2corg/ ${::lsbdistcodename} main
",
  }

  if ($::lsbdistrelease != 'testing') { # no backports available for testing
    apt::sources_list { "debian-backports":
      content => "# file managed by puppet
deb http://backports.debian.org/debian-backports ${::lsbdistcodename}-backports main contrib non-free
",
    }
  }

  apt::key { "c2corg":
    source => "http://${pkgrepo}/pubkey.txt",
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
    pin      => "release a=${::lsbdistcodename}-backports",
    priority => "50",
  }

  apt::preferences { "c2corg":
    package  => "*",
    pin      => "release l=C2corg, a=${::lsbdistcodename}",
    priority => "110",
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

  package { 'unattended-upgrades': ensure => present }

  if ($::lsbdistrelease == 'squeeze') {
    apt::preferences { "upgrade-unattended-upgrades":
      package  => "unattended-upgrades",
      pin      => "release l=C2corg, a=squeeze",
      priority => "1100",
    }
  }

  if ($::lsbdistrelease == 'testing') {
    $pattern = 'a=testing'
    $extra = ''
  } else {
    $pattern = "n=${::lsbdistcodename}"
    $extra = "o=Debian Backports,n=${::lsbdistcodename}-backports"
  }

  apt::conf { '50unattended-upgrades':
    ensure  => present,
    content => template('c2corg/apt/50unattended-upgrades.erb'),
  }

  file { '/etc/apt/apt.conf.d/99unattended-upgrade':
    ensure => absent,
  }

}
