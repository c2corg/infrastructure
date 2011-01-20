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

  #TODO: collectd

}

class c2corg::database::prod inherits c2corg::database::base {

  $pgver = "8.4"
  $logfacility = "LOCAL0"

  Augeas { context => "/files/etc/postgresql/${pgver}/main/" }
  Postgresql::Hba { pgver => $pgver }
  #Postgresql::Conf { pgver => $pgver }

  augeas { "passwd auth for local postgres connections":
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
  }

  #TODO
  #postgresql::conf {
  #  "log_statement": value => "all";
  #  "log_destination": value => "syslog";
  #  "syslog_facility": value => $logfacility;
  #  "log_line_prefix": value => "%t";
  #  "log_min_duration_statement": value => "0";
  #}

  file { "/etc/rsyslog.d/zzz-discard-postgresql-logs.conf":
    ensure  => present,
    content => "# file managed by puppet
# discard messages coming from postgresql
${logfacility}.* ~
",
    notify  => Service["syslog"],
    require => Package["syslog"],
  }

}

class c2corg::database::test inherits c2corg::database::base {

}

class c2corg::database::dev inherits c2corg::database::base {

}

