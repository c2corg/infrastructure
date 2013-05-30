class c2corg::devproxy::http {

  nginx::site { 'http-devproxy':
    source => 'puppet:///c2corg/nginx/http-devproxy.conf',
  }

  @@nat::fwd { 'forward http port':
    host  => '103',
    from  => '80',
    to    => '80',
    proto => 'tcp',
    tag   => 'portfwd',
  }

}
