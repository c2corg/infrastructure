class c2corg::devproxy {

  nginx::site { 'devproxy':
    source => 'puppet:///c2corg/nginx/devproxy.conf',
  }

  $resolvers = hiera('resolvers')

  nginx::conf { 'resolver':
    content => inline_template('# file managed by puppet
resolver <%= resolvers.join(" ") %>;
'),
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
    '/inventory.html'                       => 'inventory',
    '/pgfouine/'                            => 'pgfouine reports',
    '/haproxy-logs/'                        => 'haproxy logs',
    'https://graphite.dev.camptocamp.org/'  => 'graphite viewer',
    'http://128.179.66.23:8080/stats'       => 'haproxy stats',
  }

  file { '/srv/dev.camptocamp.org/htdocs/dashboard.html':
    ensure  => present,
    content => template('c2corg/dashboard.html.erb'),
  }

}
