class c2corg::camo {

  $camo_dir      = '/srv/camo'
  $camo_version  = 'v2.3.0'
  $camo_port     = '8081'
  $camo_logging  = 'disabled'
  $camo_hostname = 'camo.camptocamp.org'
  $camo_key      = hiera('camo_key')

  realize C2cinfra::Account::User['c2corg']

  package { 'nodejs': }

  apt::pin { 'nodejs_from_bpo':
    packages => 'nodejs',
    release  => "${::lsbdistcodename}-backports",
    priority => '1010',
  }

  vcsrepo { 'camo.camptocamp.org':
    name     => "${camo_dir}",
    owner    => 'c2corg',
    group    => 'c2corg',
    ensure   => present,
    provider => 'git',
    source   => 'https://github.com/atmos/camo.git',
    revision => $camo_version,
    notify   => Service['camo'],
  }

  file { '/etc/init.d/camo':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    content => template('c2corg/camo/camo-init.erb'),
    mode    => 0755,
    notify  => Service['camo'],
  }

  service { 'camo':
    ensure => running,
    enable => true,
  }

  file { 'logrotate configuration':
    ensure  => present,
    path    => "/etc/logrotate.d/camo",
    owner   => root,
    group   => root,
    mode    => '0644',
    content => "#file managed by puppet
${camo_dir}/log/camo.log {
  weekly
  rotate 52
  compress
  delaycompress
  missingok
  notifempty
  create 644 c2corg c2corg 
}",
    require => Package["logrotate"],
  }

}
