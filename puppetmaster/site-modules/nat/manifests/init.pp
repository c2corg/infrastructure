class nat {

  package { "netstat-nat": ensure => present }

  sysctl::value { "net.ipv4.ip_forward": value => "1" }

}
