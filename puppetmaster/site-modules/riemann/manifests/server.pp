class riemann::server {

  package { ['openjdk-7-jre-headless', 'riemann']:
    ensure => present,
  } ->

  service { 'riemann':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

  cron { 'remove old riemann logs':
    user    => 'riemann',
    minute  => '06',
    hour    => '06',
    command => 'find /var/log/riemann/ -type f -mtime +7 -delete',
  }

}
