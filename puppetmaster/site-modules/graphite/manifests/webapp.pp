class graphite::webapp {

  include graphite

  exec { "install graphite webapp":
    command => "python setup.py install --prefix /opt/graphite --install-lib /opt/graphite/webapp",
    cwd     => "/usr/src/graphite",
    creates => "/opt/graphite/webapp",
    require => Vcsrepo["/usr/src/graphite"],
  }

  # workaround for what obviously seems to be a bug !
  file { ["/opt/graphite/storage/index", "/opt/graphite/storage/.index.tmp"]:
    ensure  => present,
    owner   => "www-data",
    group   => "www-data",
    require => Exec["install graphite webapp"],
    before  => Exec["initialize graphite database"],
  }

  exec { "initialize graphite database":
    environment => ["PYTHONPATH=/opt/graphite/webapp"],
    cwd         => "/opt/graphite/webapp/graphite",
    command     => "python manage.py syncdb",
    require     => File["/opt/graphite/webapp/graphite/local_settings.py"],
    creates     => "/var/www/graphite/private/graphite/graphite.db",
    logoutput   => true,
    user        => "www-data",
  }

  file { "/opt/graphite/conf/graphite.wsgi":
    source  => "file:///opt/graphite/conf/graphite.wsgi.example",
    require => Exec["install graphite webapp"],
    before  => Apache::Directive["configure graphite"],
    notify  => Exec["apache-graceful"],
  }

  file { "/opt/graphite/webapp/graphite/local_settings.py":
    content => "# file managed by puppet
#DEBUG = True
LISTS_DIR = '/var/www/graphite/private/graphite/lists'
LOG_DIR = '/var/log/graphite/'
DATABASE_ENGINE = 'sqlite3'
DATABASE_NAME = '/var/www/graphite/private/graphite/graphite.db'
",
    require => Exec["install graphite webapp"],
    before  => Apache::Directive["configure graphite"],
    notify  => Exec["apache-graceful"],
  }

  # For some reason, STORAGE_DIR is not respected
  file { "/opt/graphite/storage":
    ensure  => link,
    force   => true,
    target  => "/srv/carbon",
    require => Exec["install graphite webapp"],
    before  => Apache::Directive["configure graphite"],
  }

  file { [
    "/var/log/graphite",
    "/var/www/graphite/private/graphite",
    "/var/www/graphite/private/graphite/lists",
  ]:
    ensure  => directory,
    owner   => "www-data",
    group   => "www-data",
    require => Exec["install graphite webapp"],
    before  => File["/opt/graphite/webapp/graphite/local_settings.py"],
  }

  package { "libapache2-mod-wsgi": }

  apache::module { "wsgi":
    ensure  => present,
    require => Package["libapache2-mod-wsgi"],
  }

  apache::listen { "8080": }
  apache::vhost { "graphite":
    ports => ['*:8080']
  }

  apache::directive { "configure graphite":
    vhost     => 'graphite',
    require   => Package["python-django"],
    directive => '# copied from https://github.com/spikelab/puppet-graphite/blob/master/files/graphite-apache-vhost.conf

        # I ve found that an equal number of processes & threads tends
        # to show the best performance for Graphite (ymmv).
        WSGIDaemonProcess graphite processes=5 threads=5 display-name="%{GROUP}" inactivity-timeout=120
        WSGIProcessGroup graphite

        # You will need to create this file! There is a graphite.wsgi.example
        # file in this directory that you can safely use, just copy it to graphite.wgsi
        WSGIScriptAlias / /opt/graphite/conf/graphite.wsgi

        Alias /content/ /opt/graphite/webapp/content/
        <Location "/content/">
                SetHandler None
                Order allow,deny
                Allow from all
        </Location>

        Alias /media/ "/usr/share/pyshared/django/contrib/admin/media/"
        <Location "/media/">
                SetHandler None
        </Location>

        # The graphite.wsgi file has to be accessible by apache. It wont
        # be visible to clients because of the DocumentRoot though.
        <Directory /opt/graphite/conf/>
                Order deny,allow
                Allow from all
        </Directory>

        <Directory "/opt/carbon/storage/rrd">
                Options -Indexes
         Order allow,deny
         Allow from all
     </Directory>
',
  }

}
