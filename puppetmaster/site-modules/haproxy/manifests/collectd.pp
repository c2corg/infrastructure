class haproxy::collectd {

  include haproxy::collectd::typesdb

  $plugin= "/usr/local/sbin/haproxy-stat.sh"

  package { "socat": }

  file { "haproxy collectd plugin":
    path    => $plugin,
    source  => "puppet:///modules/haproxy/haproxy-stat.sh",
    mode    => 0755,
    require => Package["socat"],
    notify  => Service["collectd"],
  }

  collectd::plugin { "haproxy":
    content => "# file managed by puppet
<Plugin exec>
  Exec \"haproxy:haproxy\" \"${plugin}\" \"-x\" \"c2corg\"
  Exec \"haproxy:haproxy\" \"${plugin}\" \"-x\" \"website\"
  Exec \"haproxy:haproxy\" \"${plugin}\" \"-x\" \"storage\"
</Plugin>
",
    require => [
      File["haproxy collectd plugin"],
      File["haproxy collectd types"],
      Service["haproxy"],
    ],
  }

}
