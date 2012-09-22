class c2corg::database::common inherits c2corg::database {

  include postgresql::params

  augeas { "passwd auth for local postgres connections":
    changes   => "set pg_hba.conf/*[type='local'][user='all'][database='all']/method md5",
    load_path => "/usr/share/augeas/lenses/contrib/",
    notify    => Service["postgresql"],
    require   => Package["postgresql"],
    context   => "/files/etc/postgresql/${postgresql::params::version}/main/",
  }

  postgresql::hba { "access for ml user to c2corg db":
    ensure   => present,
    type     => 'hostssl',
    database => 'c2corg',
    user     => "${c2corg::password::ml_db_user}",
    address  => '192.168.192.0/24',
    method   => 'md5',
  }

  postgresql::hba { "access for www user to c2corg db":
    ensure   => present,
    type     => 'hostssl',
    database => 'c2corg',
    user     => "${c2corg::password::www_db_user}",
    address  => '192.168.192.0/24',
    method   => 'md5',
  }

  postgresql::hba { "access for www user to metaengine db":
    ensure   => present,
    type     => 'hostssl',
    database => 'metaengine',
    user     => "${c2corg::password::www_db_user}",
    address  => '192.168.192.0/24',
    method   => 'md5',
  }

  postgresql::conf {
    "listen_addresses": value => "*";
  }

  package { ["pgtune", "sysbench", "ptop", "check-postgres"]: }

}
