class c2corg::trac {

  include apache::ssl

  $sslcert_country = "CH"
  $sslcert_organisation = "Camptocamp.org"
  apache::vhost-ssl { "dev.camptocamp.org":
    certcn  => "dev.camptocamp.org",
    sslonly => true,
    cert    => "file:///etc/puppet/dev.camptocamp.org.crt",
    certchain => "file:///usr/share/ca-certificates/cacert.org/cacert.org.crt",
    require => Package["ca-certificates"],
  }

  package { ["trac", "trac-accountmanager", "trac-email2trac", "trac-mastertickets", "trac-wikirename"]:
    ensure  => present,
    require => Package["sqlite3"],
  }

  package { ["libapache2-svn", "sqlite3", "graphviz", "libjs-jquery"]:
    ensure => present,
  }

  apache::module { "dav_svn":
    require => Package["libapache2-svn"],
  }

  apache::directive { "svn":
    vhost     => "dev.camptocamp.org",
    directive => "
<Location /svn/c2corg>
  DAV svn
  SVNPath /srv/svn/repos/c2corg

  AuthzSVNAccessFile /srv/svn/repos/c2corg/conf/svnaccess.conf

  AuthType Basic
  AuthName Subversion
  AuthUserFile /srv/trac/projects/c2corg/conf/htpasswd

  <LimitExcept GET PROPFIND OPTIONS REPORT>
    Require valid-user
  </LimitExcept>

</Location>
",
  }

  @@host { "dev.camptocamp.org":
    ip  => $ipaddress,
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
