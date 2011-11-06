class c2corg::apacheconf::prod inherits c2corg::apacheconf {

  include c2corg::apacheconf::redirections
  include apache::collectd

  # don't listen on *:80, This is haproxy's job.
  apache::listen { "${haproxy_apache_address}:80": ensure => present } # TODO: this is crap
  apache::listen { "127.0.0.1:80": ensure => present } # needed by collectd

  include disable80

  class disable80 inherits apache::base {
    Apache::Listen["80"] { ensure => absent }
  }

}
