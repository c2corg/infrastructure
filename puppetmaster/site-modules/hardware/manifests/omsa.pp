class hardware::omsa {

  case $::productname {
    /2950/:  { $version = 'OMSA_7.1' }
    /1850/:  { $version = 'OMSA_6.5' }
    default: { $version = 'latest' }
  }

  apt::key { '34D8786F': }

  apt::sources_list { 'dell-openmanage':
    content => "deb http://linux.dell.com/repo/community/deb/${version}  /\n",
  }

  apt::preferences { 'dell-openmanage':
    package  => '*',
    pin      => 'origin "linux.dell.com"',
    priority => '50',
  }

  apt::preferences { 'libsmbios2-from-dell':
    package  => 'libsmbios2',
    pin      => 'origin "linux.dell.com"',
    priority => '1100',
  }

  package { ['srvadmin-base', 'srvadmin-storageservices']:
    ensure => present,
  }

  kmod::load { 'dell_rbu': }

  service { ['snmpd', 'dataeng']:
    ensure  => stopped,
    enable  => false,
    require => [
      Kmod::Load['dell_rbu', 'ipmi_devintf', 'ipmi_si'],
      Package['srvadmin-base'],
    ],
  }
}
