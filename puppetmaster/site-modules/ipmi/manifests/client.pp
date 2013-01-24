class ipmi::client {

  package { ['ipmitool', 'freeipmi-tools']: ensure => present }

}
