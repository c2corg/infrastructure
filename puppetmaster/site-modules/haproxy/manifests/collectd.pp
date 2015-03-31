class haproxy::collectd {

  $path   = '/usr/local/lib/python2.7/site-packages'
  $plugin = "${path}/haproxy.py"

  file { 'haproxy collectd plugin':
    path    => $plugin,
    source  => 'puppet:///modules/haproxy/collectd-haproxy/haproxy.py',
    mode    => 0755,
    notify  => Service['collectd'],
  }

  collectd::config::plugin { 'haproxy':
    plugin   => 'python',
    settings => "
ModulePath \"${path}\"
Import haproxy
<Module haproxy>
  Socket \"/var/run/haproxy.sock\"
  ProxyMonitor c2corg
  ProxyMonitor c2corg_https
  ProxyMonitor website
</Module>
",
    require  => [
      File['haproxy collectd plugin'],
      Service['haproxy'],
    ],
  }

  collectd::config::plugin { 'monitor haproxy':
    plugin   => 'processes',
    settings => 'ProcessMatch "haproxy" "/usr/sbin/haproxy.*/etc/haproxy/haproxy.cfg"',
  }

}
