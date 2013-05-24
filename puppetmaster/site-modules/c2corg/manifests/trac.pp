class c2corg::trac {

  apt::preferences { "trac_from_bpo":
    package  => "trac trac-git",
    pin      => "release a=${::lsbdistcodename}-backports",
    priority => "1010",
  }

  package { ['trac', 'trac-accountmanager', 'trac-email2trac', 'trac-mastertickets', 'trac-wikirename', 'trac-git']:
    ensure  => present,
    require => Package['sqlite3'],
  }

  package { ["sqlite3", "graphviz", "libjs-jquery"]:
    ensure => present,
  }


  @@host { "dev.camptocamp.org":
    ip  => $::ipaddress,
    tag => "internal-hosts",
  }

# trac upgrade notes:
# trac-admin . upgrade
# trac-admin . wiki upgrade
# trac-admin . deploy /tmp/toto
# cp /tmp/toto/cgi-bin/trac.cgi in cgi-bin
# cp logo in htdocs
# trac-admin . resync

}
