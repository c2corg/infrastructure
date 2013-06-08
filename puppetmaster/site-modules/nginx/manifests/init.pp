class nginx ($package='nginx-full') {

  package { $package:
    ensure => present,
    alias  => 'nginx',
  } ->
  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  exec { 'reload-nginx':
    command     => '/etc/init.d/nginx reload',
    refreshonly => true,
  }

}
