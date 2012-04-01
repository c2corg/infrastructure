class nat {

  package { "netstat-nat": ensure => present }

  sysctl::set_value { "net.ipv4.ip_forward": value => "1" }

}
