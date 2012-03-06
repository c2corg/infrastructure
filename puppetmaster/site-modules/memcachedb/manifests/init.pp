class memcachedb {

  package { "memcachedb": ensure => present }

  service { "memcachedb":
    ensure    => running,
    hasstatus => false,
    enable    => true,
    require   => Package["memcachedb"],
  }

  file { "/var/lib/memcachedb":
    ensure  => directory,
    owner   => "memcachedb",
    group   => "memcachedb",
    require => Package["memcachedb"],
    before  => Service["memcachedb"],
  }

  file { "/etc/memcachedb.conf":
    ensure  => present,
    source  => "puppet:///memcachedb/memcachedb.conf",
    notify  => Service["memcachedb"],
    require => Package["memcachedb"],
  }

  cron { "db_archive":
    command => 'echo -e "db_archive\r\nquit" | nc -q 2 localhost 11211 | logger -t "memcachedb db_archive" 2>&1',
    user    => "memcachedb",
    minute  => "34",
    hour    => "*/4",
    require => Service["memcachedb"],
  }

  #TODO: logrotate without restarting, memcachedb doesn't like -HUP

}
