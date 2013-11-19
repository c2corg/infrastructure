define c2cinfra::metrics::alias ($target) {

  @@file { "/var/lib/graphite/whisper/aliases/${name}":
    ensure => symlink,
    target => "/var/lib/graphite/whisper/$target",
    tag    => 'metrics-aliases',
  }
}
