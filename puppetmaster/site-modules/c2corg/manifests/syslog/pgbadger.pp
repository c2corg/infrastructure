class c2corg::syslog::pgbadger {

  package { ['pgbadger', 'libtext-csv-xs-perl']: ensure => present }

  file { ['/srv/logs', '/srv/logs/postgresql']:
    ensure => directory,
  }

  file { '/srv/logs/postgresql/csvlogs':
    ensure => directory,
    owner  => 'logstash',
    group  => 'logstash',
  }

  file { '/srv/logs/postgresql/reports':
    ensure => directory,
    owner  => 'nobody',
    group  => 'nogroup',
  }

  cron { 'process yesterdays pgsql logs':
    user    => 'nobody',
    minute  => '15',
    hour    => '00',
    command => '/usr/bin/pgbadger -I -q /srv/logs/postgresql/csvlogs/pglog-$(/bin/date --date="yesterday" +\%d)-*.csv -O /srv/logs/postgresql/reports/',
  }

  cron { 'purge old pgsql raw logs':
    user    => 'logstash',
    minute  => '45',
    hour    => '00',
    command => 'find /srv/logs/postgresql/csvlogs/ -type f -mtime +3 -delete',
  }

  ::nginx::site { 'pgbadger':
    source => 'puppet:///modules/c2corg/nginx/pgbadger.conf',
  }

}
