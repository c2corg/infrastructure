class c2cinfra::devproxy {

  include '::nginx::monitoring'

  nginx::site { 'devproxy':
    source => 'puppet:///modules/c2cinfra/nginx/devproxy.conf',
  }

  $resolvers = hiera('resolvers')

  nginx::conf { 'resolver':
    content => inline_template('# file managed by puppet
resolver <%= @resolvers.join(" ") %>;
'),
  }

  file { '/etc/nginx/c2cauth.conf':
    ensure  => present,
    notify  => Exec['reload-nginx'],
    content => '# file managed by puppet
auth_basic "use your Trac username and password";
auth_basic_user_file /srv/trac/projects/c2corg/conf/htpasswd;
',
  }

  @@nat::fwd { 'forward http port':
    host  => '103',
    from  => '80',
    to    => '80',
    proto => 'tcp',
    tag   => 'portfwd',
  }

  @@nat::fwd { 'forward https port':
    host  => '103',
    from  => '443',
    to    => '443',
    proto => 'tcp',
    tag   => 'portfwd',
  }

  file { ['/srv/dev.camptocamp.org', '/srv/dev.camptocamp.org/htdocs']:
    ensure => directory,
  }

  $dashboard = {
    '/inventory.html'                         => 'inventory',
    '/pgreports'                              => 'pgbadger reports',
    '/haproxy-logs'                           => 'haproxy logs',
    'https://graphite.dev.camptocamp.org/'    => 'graphite viewer',
    'https://puppetboard.dev.camptocamp.org/' => 'puppet dashboard',
    'http://128.179.66.23:8008/stats'         => 'haproxy stats',
  }

  file { '/srv/dev.camptocamp.org/htdocs/dashboard.html':
    ensure  => present,
    content => template('c2cinfra/dashboard.html.erb'),
  }

}
