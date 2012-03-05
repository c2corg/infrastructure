class c2corg::apacheconf::prod inherits c2corg::apacheconf {

  include c2corg::apacheconf::redirections
  include apache::collectd

  include c2corg::prod::apache::disable80

  # don't listen on *:80, This is haproxy's job.
  apache::listen { "${haproxy_main_address}:80": ensure => present } # TODO: this is crap
  apache::listen { "127.0.0.1:80": ensure => present } # needed by collectd

  if ($hostname !~ /failover/) {

    xcache::param {
      "xcache/xcache.size":  value => "128M";
      "xcache/xcache.count": value => "12";
    }
  }

}
