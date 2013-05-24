class c2corg::trac {

  include apache::ssl

  $sslcert_country = "CH"
  $sslcert_organisation = "Camptocamp.org"
  apache::vhost::ssl { "dev.camptocamp.org":
    certcn  => "dev.camptocamp.org",
    sslonly => true,
    cert    => "file:///etc/puppet/dev.camptocamp.org.crt",
    certkey => "file:///etc/puppet/dev.camptocamp.org.key",
    certchain => "file:///usr/share/ca-certificates/cacert.org/cacert.org.crt",
    require => Package["ca-certificates"],
  }

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

  apache::directive { "trac":
    vhost     => "dev.camptocamp.org",
    directive => "
Alias /tracdocs/ /usr/share/pyshared/trac/htdocs/

ScriptAlias /trac/c2corg /var/www/dev.camptocamp.org/cgi-bin/trac.cgi
",
  }

# trac upgrade notes:
# trac-admin . upgrade
# trac-admin . wiki upgrade
# trac-admin . deploy /tmp/toto
# cp /tmp/toto/cgi-bin/trac.cgi in cgi-bin
# cp logo in htdocs
# trac-admin . resync

}
