class c2corg::webserver::ipv6gw {

  include nginx

  nginx::site { "ipv6gw":
    conf_source => "c2corg/nginx/ipv6gw.erb",
  }
}
