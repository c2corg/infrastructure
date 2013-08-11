class c2corg::webserver::ipv6gw {

  include '::nginx'
  include '::nginx::monitoring'

  nginx::site { 'ipv6gw':
    source => 'puppet:///modules/c2corg/nginx/ipv6gw.conf',
  }
}
