class c2corg::database::prod inherits c2corg::database::common {

  include '::logstash'

  $www_db_user   = hiera('www_db_user')
  $prod_db_pass  = hiera('prod_db_pass')
  $monit_db_user = hiera('monit_db_user')
  $logstash_host = hiera('logstash_host')

  Postgresql::Server::Role[$www_db_user] {
    password_hash => postgresql_password($www_db_user, hiera('prod_db_pass')),
  }

  postgresql::server::config_entry {
    'log_statement'              : value => 'all';
    'log_destination'            : value => 'csvlog';
    'logging_collector'          : value => 'on';
    'log_duration'               : value => 'on';
    'log_line_prefix'            : value => '%t';
    'log_min_duration_statement' : value => '0';
    'log_error_verbosity'        : value => 'VERBOSE';
    'log_directory'              : value => '/var/log/postgresql';
    'log_filename'               : value => 'postgresql-%H.log';
    'log_truncate_on_rotation'   : value => 'on';
    'log_rotation_size'          : value => '0';
    'log_rotation_age'           : value => '60';
    'log_file_mode'              : value => '0644';
    'syslog_facility'            : ensure => absent;
  }

  etcdefault { 'minimal memory for logstash shipper':
    file    => 'logstash',
    key     => 'LS_JAVA_OPTS',
    value   => '"-Xmx64m -Djava.io.tmpdir=/var/lib/logstash/"',
    notify  => Service['logstash'],
    require => Package['logstash'],
  }

  file { '/etc/logstash/conf.d/csvshipper.conf':
    ensure  => present,
    content => inline_template('# file managed by puppet
input {
  file {
    path => "/var/log/postgresql/postgresql-*.csv"
    codec => multiline {
      pattern => "^%{TIMESTAMP_ISO8601} "
      negate  => true
      what    => previous
    }
    type => "postgresql"
  }
}

filter {
  csv {
    columns => [ "pg.log_time", "pg.user_name", "pg.database_name", "pg.process_id", "pg.connection_from", "pg.session_id", "pg.session_line_num", "pg.command_tag", "pg.session_start_time", "pg.virtual_transaction_id", "pg.transaction_id", "pg.error_severity", "pg.sql_state_code", "pg.message", "pg.detail", "pg.hint", "pg.internal_query", "pg.internal_query_pos", "pg.context", "pg.query", "pg.query_pos", "pg.location", "pg.application_name" ]
  }
}

output {
  tcp {
    codec => "json"
    host  => "<%= logstash_host %>"
    port  => "55514"
  }
}
'),
    notify  => Service['logstash'],
    require => Package['logstash'],
  }

  file { '/etc/rsyslog.d/zzz-discard-postgresql-logs.conf':
    ensure  => absent,
    notify  => Service['syslog'],
  }

  postgresql::server::role { $monit_db_user:
    password_hash => postgresql_password($monit_db_user, hiera('monit_db_pass')),
    superuser     => true,
  }

  collectd::config::plugin { 'postgresql plugin config':
    plugin   => 'postgresql',
    settings => "
  <Database c2corg>
    Port \"5432\"
    User \"${monit_db_user}\"
    Password \"${monit_db_pass}\"
  </Database>
",
  }

  collectd::config::plugin { 'monitor postgres process':
    plugin   => 'processes',
    settings => 'Process postgres',
  }

}
