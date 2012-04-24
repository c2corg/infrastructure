class ipmi {

  package { 'ipmitool': ensure => present }

  kmod::install { ['ipmi_devintf', 'ipmi_si']:
    ensure => present,
    before => Collectd::Plugin['ipmi'],
  }

  collectd::plugin { 'ipmi': lines => [] }

}
