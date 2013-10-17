class c2corg::memcached {

  package { "php5-memcache":
    ensure => present,
  }

  $session_hosts = hiera('session_hosts')

  file { '/etc/php5/apache2/conf.d/memcached-session-settings.ini':
    ensure  => present,
    content => inline_template('; file managed by puppet
[Session]
session.save_path=<%= session_hosts.map { |host| "tcp://#{host}:11211" }.join(",") %>

[memcache]
; apparent off by one error: session_redundancy needs to be set to N+1 for a
; redundancy of N
memcache.session_redundancy=<%= session_hosts.count + 1 %>
memcache.allow_failover=1
'),
    require => [Package['php5-memcache'], Package['apache']],
    notify  => Service['apache'],
  }

  augeas { 'enable memcache session storage':
    changes => [
      'set Session/session.save_handler memcache',
      'rm Session/session.save_path',
    ],
    incl    => '/etc/php5/apache2/php.ini',
    lens    => 'PHP.lns',
    require => Package['php5-memcache'],
    notify  => Service['apache'],
  }
}
