class c2corg::devproxy::http {

  nginx::site { 'http-devproxy':
    source => 'puppet:///c2corg/nginx/http-devproxy.conf',
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

}
