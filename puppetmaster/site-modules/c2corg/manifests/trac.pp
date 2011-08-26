class c2corg::trac {

  include apache::ssl

  $sslcert_country = "CH"
  $sslcert_organisation = "Camptocamp.org"
  apache::vhost-ssl { "dev.camptocamp.org":
    certcn  => "dev.camptocamp.org",
    sslonly => true,
  }

  package { ["trac", "libapache2-svn", "sqlite3"]: ensure => present }

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

  apache::directive { "trac":
    vhost     => "dev.camptocamp.org",
    directive => "
Alias /tracdocs/ /usr/share/pyshared/trac/htdocs/

ScriptAlias /trac/c2corg /var/www/dev.camptocamp.org/cgi-bin/trac.cgi
",
  }

}
