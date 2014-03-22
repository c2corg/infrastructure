class apache {

  include apache::params
  include concat::setup

  $access_log = $apache::params::access_log
  $error_log  = $apache::params::error_log

  concat {"${apache::params::conf}/ports.conf":
    notify  => Service['apache'],
    require => Package['apache'],
  }

  # removed this folder originally created by common::concatfilepart
  file {"${apache::params::conf}/ports.conf.d":
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
  }

  file {"root directory":
    path => $apache::params::root,
    ensure => directory,
    mode => '0755',
    owner => "root",
    group => "root",
    require => Package["apache"],
  }

  file {"log directory":
    path => $apache::params::log,
    ensure => directory,
    mode => '0755',
    owner => "root",
    group  => "root",
    require => Package["apache"],
  }

  user { "apache user":
    name    => $apache::params::user,
    ensure  => present,
    require => Package["apache"],
    shell   => "/bin/sh",
  }

  group { "apache group":
    name    => $apache::params::user,
    ensure  => present,
    require => Package["apache"],
  }

  package { "apache":
    name   => $apache::params::pkg,
    ensure => installed,
  }

  service { "apache":
    name       => $apache::params::pkg,
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package["apache"],
  }

  apache::listen { "80": ensure => present }
  apache::namevhost { "*:80": ensure => present }

  apache::module {["alias", "auth_basic", "authn_file", "authz_default", "authz_groupfile", "authz_host", "authz_user", "autoindex", "dir", "env", "mime", "negotiation", "rewrite", "setenvif", "status", "cgi"]:
    ensure => present,
    notify => Exec["apache-graceful"],
  }

  file {"default status module configuration":
    path => "${apache::params::conf}/mods-available/status.conf",
    ensure => present,
    owner => root,
    group => root,
    source => "puppet:///modules/${module_name}/etc/apache2/mods-available/status.conf",
    require => Module["status"],
    notify => Exec["apache-graceful"],
  }

  file {"default virtualhost":
    path    => "${apache::params::conf}/sites-available/default-vhost",
    ensure  => present,
    content => template("apache/default-vhost.erb"),
    require => Package["apache"],
    notify  => Exec["apache-graceful"],
    before  => File["${apache::params::conf}/sites-enabled/000-default-vhost"],
    mode    => '0644',
  }

  if str2bool(hiera('apache_disable_default_vhost')) {

    file { "${apache::params::conf}/sites-enabled/000-default-vhost":
      ensure => absent,
      notify => Exec['apache-graceful'],
    }

  } else {

    file { "${apache::params::conf}/sites-enabled/000-default-vhost":
      ensure => link,
      target => "${apache::params::conf}/sites-available/default-vhost",
      notify => Exec['apache-graceful'],
    }

    file { "${apache::params::root}/html":
      ensure  => directory,
    }

  }

  exec { "apache-graceful":
    command     => "apache2ctl graceful",
    onlyif      => "apache2ctl configtest",
    refreshonly => true,
  }

  file {"/usr/local/bin/htgroup":
    ensure => present,
    owner => root,
    group => root,
    mode => '0755',
    source => "puppet:///modules/${module_name}/usr/local/bin/htgroup",
  }

  file { ["${apache::params::conf}/sites-enabled/default",
          "${apache::params::conf}/sites-enabled/000-default",
          "${apache::params::conf}/sites-enabled/default-ssl"]:
    ensure => absent,
    notify => Exec["apache-graceful"],
  }

  $mpm_package = $apache_mpm_type ? {
    "" => "apache2-mpm-prefork",
    default => "apache2-mpm-${apache_mpm_type}",
  }

  package { "${mpm_package}":
    ensure  => installed,
    require => Package["apache"],
  }

  # directory not present in lenny
  file { "${apache::params::root}/apache2-default":
    ensure => absent,
    force  => true,
  }

  file { "${apache::params::root}/index.html":
    ensure => absent,
  }

  file { "${apache::params::root}/html/index.html":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => "<html><body><h1>It works!</h1></body></html>\n",
  }

  file { "${apache::params::conf}/conf.d/servername.conf":
    content => "ServerName ${::fqdn}\n",
    notify  => Service["apache"],
    require => Package["apache"],
  }

  # the following variables are used in template logrotate-httpd.erb
  $logrotate_paths = "${apache::params::root}/*/logs/*.log ${apache::params::log}/*log"
  $httpd_pid_file = "/var/run/apache2.pid"

  file {"logrotate configuration":
    ensure => present,
    path  => "/etc/logrotate.d/apache2",
    owner => root,
    group => root,
    mode => '0644',
    content => template("${module_name}/logrotate-httpd.erb"),
    source => undef,
    require => Package["apache"],
  }
}
