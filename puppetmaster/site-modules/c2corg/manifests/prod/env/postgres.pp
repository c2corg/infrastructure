class c2corg::prod::env::postgres {

  Sysctl::Value { before => Service["postgresql"] }

  postgresql::conf {
    # values suggested by pgtune
    "maintenance_work_mem":         value => "960MB";
    "checkpoint_completion_target": value => "0.7";
    "effective_cache_size":         value => "11GB";
    "work_mem":                     value => "80MB";
    "wal_buffers":                  value => "4MB";
    "checkpoint_segments":          value => "8";
    "shared_buffers":               value => "3840MB";
    "max_connections":              value => "200";

    # enable activits statistics
    "track_activities": value => "on";
    "track_counts":     value => "on";
    "track_functions":  value => "none";
  }

  sysctl::value {
    "kernel.shmmax": value => "4127514624";
    "kernel.shmall": value => "2097152";
  }

}
