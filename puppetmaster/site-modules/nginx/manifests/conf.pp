define nginx::conf ($ensure=present, source=undef, content=undef) {

  file { "/etc/nginx/conf.d/${name}.conf":
    ensure  => $ensure,
    source  => $source,
    content => $content,
    require => Package['nginx'],
    notify  => Exec['reload-nginx'],
  }

}
