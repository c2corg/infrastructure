class c2corg::prod::env::postgres {

  Sysctl::Value { before => Service['postgresql'] }

  postgresql::server::config_entry {
    # values suggested by pgtune
    'maintenance_work_mem':         value => '960MB';
    'checkpoint_completion_target': value => '0.7';
    'effective_cache_size':         value => '11GB';

    'wal_buffers':                  value => '4MB';
    'checkpoint_segments':          value => '8';
    'shared_buffers':               value => '3840MB';

    # must be large enough to avoid using temp tables on disk, but can
    # exhaust memory (worst case is: work_mem * nr of sorts * max_connections)
    'work_mem':                     value => '100MB';

    # never seen more than 10, except around 30 on startup
    'max_connections':              value => '50';

    # enable activits statistics
    'track_activities': value => 'on';
    'track_counts':     value => 'on';
    'track_functions':  value => 'none';
  }

  sysctl::value {
    'kernel.shmmax': value => '4131987456';
    'kernel.shmall': value => '2097152';
  }

}
