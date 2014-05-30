class ipmi::riemann {

  $riemann_host = hiera('riemann_host')

  include riemann::client::python

  file { '/usr/local/sbin/ipmi-riemann.py':
    ensure  => present,
    mode    => '0755',
    source  => 'puppet:///modules/ipmi/ipmi-riemann.py',
    require => Class['ipmi::setup', 'riemann::client::python'],
  } ->

  cron { 'ipmi-riemann':
    command => "/usr/bin/timeout -s 9 30 /usr/local/sbin/ipmi-riemann.py ${riemann_host} 600",
    minute  => '*/5',
  }

}
