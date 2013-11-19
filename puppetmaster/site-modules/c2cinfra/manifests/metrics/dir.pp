define c2cinfra::metrics::dir () {

  @@file { "/var/lib/graphite/whisper/aliases/${name}":
    ensure => directory,
    tag    => 'metrics-aliases',
  }
}
