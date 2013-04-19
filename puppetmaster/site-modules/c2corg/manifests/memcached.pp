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
'),
    require => Package['php5-memcache'],
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
