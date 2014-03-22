class c2cinfra::metrics::aliases {

  file { [
    '/var/lib/graphite/whisper/aliases',
    '/var/lib/graphite/whisper/aliases/by-hardware-node',
    '/var/lib/graphite/whisper/aliases/by-duty',
    '/var/lib/graphite/whisper/aliases/by-duty/prod',
    '/var/lib/graphite/whisper/aliases/by-duty/preprod',
    '/var/lib/graphite/whisper/aliases/by-duty/dev',
    ]:
     ensure  => directory,
     purge   => true,
     recurse => true,
     force   => true,
  }

  File <<| tag == 'metrics-aliases' |>>
}
