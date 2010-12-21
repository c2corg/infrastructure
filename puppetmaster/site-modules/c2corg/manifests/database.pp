class c2corg::database::base {

  include postgresql
  include postgis

  include c2corg::password

  postgis::database { ["c2corg", "metaengine"]:
    ensure  => present,
    owner   => "www-data",
    require => Postgresql::User["www-data"],
  }

  postgresql::user { "www-data":
    ensure   => present,
    password => $c2corg::password::pgsql,
  }

  postgresql::user { "sympa":
    ensure   => present,
    password => $c2corg::password::sympa,
  }


}

class c2corg::database::prod inherits c2corg::database::base {

  augeas { "passwd auth for local postgres connections":
    context   => "/files/etc/postgresql/8.4/main/",
    changes   => "set pg_hba.conf/*[type='local'][user='all'][database='all']/method md5",
    load_path => "/usr/share/augeas/lenses/contrib/",
    notify    => Service["postgresql"],
    require   => Package["postgresql"],
  }

  postgresql::hba { "access to sympa user":
    ensure   => present,
    type     => 'host',
    database => 'c2corg',
    user     => 'sympa',
    address  => '192.168.0.0/16',
    method   => 'md5',
    pgver    => '8.4',
  }

}

class c2corg::database::test inherits c2corg::database::base {

}

class c2corg::database::dev inherits c2corg::database::base {

}

