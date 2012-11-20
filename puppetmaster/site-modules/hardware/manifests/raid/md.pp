class hardware::raid::md {

  package { 'mdadm': ensure => present }

  # TODO: monitoring, etc
}
