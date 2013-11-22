class c2corg::database::prod inherits c2corg::database::common {

  $logfacility = 'LOCAL0'

  $www_db_user  = hiera('www_db_user')
  $prod_db_pass = hiera('prod_db_pass')

  Postgresql::Server::Role[$www_db_user] {
    password_hash => postgresql_password($www_db_user, hiera('prod_db_pass')),
  }


  postgresql::server::config_entry {
    'log_statement'              : value => 'all';
    'log_destination'            : value => 'syslog';
    'syslog_facility'            : value => $logfacility;
    'log_line_prefix'            : value => '%t';
    'log_min_duration_statement' : value => '0';
  }

  file { '/etc/rsyslog.d/zzz-discard-postgresql-logs.conf':
    ensure  => present,
    content => "# file managed by puppet
# discard messages coming from postgresql
${logfacility}.* ~
",
    notify  => Service['syslog'],
    require => Package['syslog'],
  }

  collectd::config::plugin { 'postgresql plugin config':
    plugin   => 'postgresql',
    settings => "
  <Database c2corg>
    Port \"5432\"
    User \"${www_db_user}\"
    Password \"${prod_db_pass}\"
  </Database>
",
  }

  collectd::config::plugin { 'monitor postgres process':
    plugin   => 'processes',
    settings => 'Process postgres',
  }

}
