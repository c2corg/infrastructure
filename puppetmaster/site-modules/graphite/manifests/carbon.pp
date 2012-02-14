class graphite::carbon {

  include graphite

  exec { "install carbon":
    command => "python setup.py install --prefix /opt/carbon --install-lib /opt/carbon/lib",
    cwd     => "/usr/src/graphite/carbon",
    creates => "/opt/carbon/lib/carbon",
    require => Vcsrepo["/usr/src/graphite"],
  }

  exec { "install whisper":
    command => "python setup.py install --prefix /opt/whisper",
    cwd     => "/usr/src/graphite/whisper",
    creates => "/opt/whisper",
    require => Vcsrepo["/usr/src/graphite"],
  }

  user { "carbon":
    ensure => present,
    home   => "/var/lib/carbon/",
  }

  # For some reason, STORAGE_DIR is not respected
  file { "/opt/carbon/storage":
    ensure  => link,
    force   => true,
    target  => "/var/lib/carbon",
    require => Exec["install carbon"],
    before  => Service["carbon"],
  }

  file { ["/var/lib/carbon/", "/var/log/carbon/"]:
    ensure => directory,
    owner  => "carbon",
    group  => "carbon",
    before => Service["carbon"],
  }

  file { "/etc/carbon/": ensure => directory }

  file { "/etc/carbon/carbon.conf":
    ensure  => present,
    notify  => Service["carbon"],
    content => "# file managed by puppet
[cache]
STORAGE_DIR = /var/lib/carbon/
CONF_DIR    = /etc/carbon/
LOG_DIR     = /var/log/carbon/carbon
PID_DIR     = /var/run/
USER        = carbon

# values found in carbon.conf.example
MAX_CACHE_SIZE = inf
MAX_UPDATES_PER_SECOND = 1000
MAX_CREATES_PER_MINUTE = 50
LINE_RECEIVER_INTERFACE = 0.0.0.0
LINE_RECEIVER_PORT = 2003
ENABLE_UDP_LISTENER = False
UDP_RECEIVER_INTERFACE = 0.0.0.0
UDP_RECEIVER_PORT = 2003
PICKLE_RECEIVER_INTERFACE = 0.0.0.0
PICKLE_RECEIVER_PORT = 2004
USE_INSECURE_UNPICKLER = False
CACHE_QUERY_INTERFACE = 0.0.0.0
CACHE_QUERY_PORT = 7002
USE_FLOW_CONTROL = True
LOG_UPDATES = False
WHISPER_AUTOFLUSH = False
[relay]
LINE_RECEIVER_INTERFACE = 0.0.0.0
LINE_RECEIVER_PORT = 2013
PICKLE_RECEIVER_INTERFACE = 0.0.0.0
PICKLE_RECEIVER_PORT = 2014
RELAY_METHOD = rules
REPLICATION_FACTOR = 1
DESTINATIONS = 127.0.0.1:2004
MAX_DATAPOINTS_PER_MESSAGE = 500
MAX_QUEUE_SIZE = 10000
USE_FLOW_CONTROL = True
[aggregator]
LINE_RECEIVER_INTERFACE = 0.0.0.0
LINE_RECEIVER_PORT = 2023
PICKLE_RECEIVER_INTERFACE = 0.0.0.0
PICKLE_RECEIVER_PORT = 2024
DESTINATIONS = 127.0.0.1:2004
REPLICATION_FACTOR = 1
MAX_QUEUE_SIZE = 10000
USE_FLOW_CONTROL = True
MAX_DATAPOINTS_PER_MESSAGE = 500
MAX_AGGREGATION_INTERVALS = 5
",
  }

  file { "/etc/carbon/storage-schemas.conf":
    ensure  => present,
    notify  => Service["carbon"],
    content => "# file managed by puppet
[carbon]
pattern = ^carbon\.
retentions = 60:90d

[default_1min_for_1day]
pattern = .*
retentions = 60s:1d
",
  }

  file { "/etc/init.d/carbon":
    source => "puppet:///graphite/carbon.init",
    mode   => 0755,
    before => Service["carbon"],
  }

  service { "carbon":
    ensure    => running,
    hasstatus => true,
    enable    => true,
    require   => [
      File["/etc/carbon/carbon.conf"],
      User["carbon"],
      Exec["install carbon"],
      Exec["install whisper"],
    ],
  }

}
