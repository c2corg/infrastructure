class c2cinfra::collectd::plugin::svninfo {

  $plugin= '/usr/local/sbin/svninfo-stat.sh'

  file { 'svninfo collectd plugin':
    path    => $plugin,
    source  => 'puppet:///modules/c2cinfra/collectd/svninfo-stat.sh',
    mode    => 0755,
    notify  => Service['collectd'],
  }

  collectd::config::plugin { 'svninfo-c2corg':
    plugin   => 'exec',
    settings => "Exec \"c2corg:c2corg\" \"${plugin}\" \"-i\" \"c2corg\" \"-d\" \"/srv/www/camptocamp.org\"",
    require  => Vcsrepo['camptocamp.org'],
  }

  collectd::config::plugin { 'svninfo-meta':
    plugin   => 'exec',
    settings => "Exec \"c2corg:c2corg\" \"${plugin}\" \"-i\" \"meta\" \"-d\" \"/srv/www/meta.camptocamp.org\"",
    require  => Vcsrepo['camptocamp.org'],
  }

}
