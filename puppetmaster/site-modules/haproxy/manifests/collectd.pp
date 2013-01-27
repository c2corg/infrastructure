class haproxy::collectd {

  $plugin= '/usr/local/sbin/haproxy-stat.sh'

  package { 'socat': }

  file { 'haproxy collectd plugin':
    path    => $plugin,
    source  => 'puppet:///modules/haproxy/haproxy-stat.sh',
    mode    => 0755,
    require => Package['socat'],
    notify  => Service['collectd'],
  }

  collectd::config::plugin { 'haproxy':
    plugin   => 'exec',
    settings => "
  Exec \"haproxy:haproxy\" \"${plugin}\" \"-x\" \"c2corg\"
  Exec \"haproxy:haproxy\" \"${plugin}\" \"-x\" \"website\"
  Exec \"haproxy:haproxy\" \"${plugin}\" \"-x\" \"storage\"
",
    require  => [
      File['haproxy collectd plugin'],
      File['haproxy collectd types'],
      Service['haproxy'],
    ],
  }

}
