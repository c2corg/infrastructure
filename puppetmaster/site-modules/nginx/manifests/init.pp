class nginx ($package='nginx-full') {

  if $::lsbdistcodename == 'squeeze' {
    apt::preferences { "nginx_from_bpo":
      package  => "nginx nginx-full nginx-extras nginx-common nginx-light nginx-naxsi",
      pin      => "release a=${::lsbdistcodename}-backports",
      priority => "1010",
    }
  }

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
