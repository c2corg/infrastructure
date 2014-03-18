class hardware::raid::md {

  Etcdefault {
    file   => 'mdadm',
    notify => Service['mdadm'],
  }

  package { 'mdadm': ensure => present } ->

  etcdefault {
    'enable mdadm at boot':            key => 'AUTOSTART',    value => 'true';
    'enable mdadm monitoring at boot': key => 'START_DAEMON', value => 'true';
  } ->

  augeas { 'set mdadm mail address':
    changes => 'set mailaddr/value root',
    incl    => '/etc/mdadm/mdadm.conf',
    lens    => 'Mdadm_conf.lns',
    notify  => Service['mdadm'],
  } ~>

  service { 'mdadm':
     ensure    => running,
     enable    => true,
     hasstatus => true,
     require   => Package['mdadm'],
  }

  collectd::plugin { 'md': }

}
