class c2corg::collectd::plugin::svninfo {

  $plugin= "/usr/local/sbin/svninfo-stat.sh"

  file { "svninfo collectd plugin":
    path    => $plugin,
    source  => "puppet:///c2corg/collectd/svninfo-stat.sh",
    mode    => 0755,
    notify  => Service["collectd"],
  }

  collectd::plugin { "svninfo-c2corg":
    content => "# file managed by puppet
<Plugin exec>
  Exec \"c2corg:c2corg\" \"${plugin}\" \"-i\" \"c2corg\" \"-d\" \"/srv/www/camptocamp.org\"
</Plugin>
",
    require => [
      Vcsrepo["camptocamp.org"],
    ],
  }

  collectd::plugin { "svninfo-meta":
    content => "# file managed by puppet
<Plugin exec>
  Exec \"c2corg:c2corg\" \"${plugin}\" \"-i\" \"meta\" \"-d\" \"/srv/www/meta.camptocamp.org\"
</Plugin>
",
    require => [
      Vcsrepo["meta.camptocamp.org"],
    ],
  }

}
