class riemann::dash {

  include '::runit'

  package { ['ruby-riemann-dash', 'ruby-sinatra', 'ruby-multi-json', 'ruby-erubis', 'ruby-sass', 'ruby-fog']:
    ensure => present,
  } ->

  file { '/var/lib/riemann-dash':
    ensure => directory,
    owner  => 'riemann',
    group  => 'riemann',
  } ->

  file { '/var/lib/riemann-dash/config.rb':
    ensure  => present,
    content => '# file managed by puppet
set :port, 8080
config[:ws_config] = "/etc/riemann/config.json"
',
  } ~>

  runit::service { 'riemann-dash':
    user    => 'riemann',
    group   => 'riemann',
    rundir  => '/var/lib/riemann-dash',
    logdir  => '/var/log/riemann-dash',
    command => '/usr/bin/riemann-dash 2>&1',
  }

}
