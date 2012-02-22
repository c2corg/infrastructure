class c2corg::database::prod inherits c2corg::database::common {

  include c2corg::password

  $logfacility = "LOCAL0"

  Postgresql::User["${c2corg::password::www_db_user}"] {
    password => $c2corg::password::prod_db_pass,
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

  collectd::plugin { "postgresql":
    content => "# file managed by puppet
LoadPlugin \"postgresql\"
<Plugin postgresql>
  <Database c2corg>
    Port \"5432\"
    User \"${c2corg::password::www_db_user}\"
    Password \"${c2corg::password::prod_db_pass}\"
  </Database>
</Plugin>
",
  }

  collectd::plugin { "processes":
    content => '# Avoid LoadPlugin as processes is already loaded elsewhere
<Plugin processes>
  Process "postgres"
</Plugin>
',
  }

}
