class c2corg::database::prod inherits c2corg::database::common {

  $www_db_user   = hiera('www_db_user')
  $prod_db_pass  = hiera('prod_db_pass')
  $monit_db_user = hiera('monit_db_user')
  $monit_db_pass = hiera('monit_db_pass')
  $logfacility   = 'LOCAL0'

  Postgresql::Server::Role[$www_db_user] {
    password_hash => postgresql_password($www_db_user, hiera('prod_db_pass')),
  }

  postgresql::server::config_entry {
    'log_statement'              : value => 'all';
    'log_destination'            : value => 'syslog';
    'syslog_facility'            : value => "${logfacility}";
    'logging_collector'          : value => 'off';
    'log_duration'               : value => 'on';
    'log_line_prefix'            : value => '%t';
    'log_min_duration_statement' : value => '0';
    'log_error_verbosity'        : value => 'VERBOSE';
    'log_temp_files'             : value => '0';
    'log_lock_waits'             : value => 'on';
    'log_filename'               : ensure => absent;
    'log_truncate_on_rotation'   : ensure => absent;
    'log_rotation_size'          : ensure => absent;
    'log_rotation_age'           : ensure => absent;
    'log_file_mode'              : ensure => absent;
    'log_directory'              : ensure => absent;
  }

  file { '/etc/rsyslog.d/zzz-discard-postgresql-logs.conf':
    content => "# file managed by puppet
# discard messages coming from postgresql
${logfacility}.* ~
",
    notify  => Service['syslog'],
  }

  postgresql::server::role { $monit_db_user:
    password_hash => postgresql_password($monit_db_user, $monit_db_pass),
    superuser     => true,
  }

  collectd::config::plugin { 'postgresql plugin config':
    plugin   => 'postgresql',
    settings => "
# calculate replication lag in bytes
  <Query replication_lag>
    Statement \"SELECT client_addr, \\
      sent_offset - ( replay_offset - (sent_xlog - replay_xlog) * 255 * 16 ^ 6 ) \\
      AS byte_lag FROM ( \\
        SELECT client_addr, \\
        ('x'||split_part(sent_location, '/', 1))::text::bit(32)::integer AS sent_xlog, \\
        ('x'||split_part(replay_location, '/', 1))::text::bit(32)::integer AS replay_xlog, \\
        ('x'||split_part(sent_location, '/', 2))::text::bit(32)::integer AS sent_offset, \\
        ('x'||split_part(replay_location, '/', 2))::text::bit(32)::integer AS replay_offset \\
        FROM pg_stat_replication) \\
      AS s;\"
    <Result>
      Type gauge
      InstancePrefix repl_lag
      InstancesFrom client_addr
      ValuesFrom byte_lag
    </Result>
    MinVersion 90100
  </Query>
  <Database c2corg>
    Port \"5432\"
    User \"${monit_db_user}\"
    Password \"${monit_db_pass}\"
    Query backends
    Query transactions
    Query queries
    Query query_plans
    Query table_states
    Query disk_io
    Query disk_usage
    Query queries_by_table
    Query query_plans_by_table
    Query table_states_by_table
    Query disk_io_by_table
    Query replication_lag
  </Database>
",
  }

  collectd::config::chain { 'IgnoreTempTables':
    type     => 'precache',
    targets  => ['stop', 'write'],
    matches  => ['regex'],
    settings => '
<Rule "ignore_pgsql_temp_tables">
  <Match "regex">
    Plugin "^postgresql$"
    TypeInstance "pg_temp_.+_tmp_table"
  </Match>
  Target "stop"
</Rule>
',
  }

  collectd::config::plugin { 'monitor postgres process':
    plugin   => 'processes',
    settings => 'Process postgres',
  }

}
