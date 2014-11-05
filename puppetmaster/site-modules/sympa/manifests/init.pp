class sympa($dbhost, $dbport, $dbtype, $dbname, $dbuser, $dbpwd, $hname, $listmaster) {

  apt::pin { 'sympa_from_c2corg_repo':
    packages => 'sympa',
    label    => 'C2corg',
    release  => "${::lsbdistcodename}",
    priority => '1010',
  }


  package { ['sympa', 'libdbd-pg-perl']:
    ensure => present,
  }

  file { "/etc/sympa/sympa.conf":
    ensure  => present,
    content => template("sympa/sympa.conf.erb"),
    require => Package["sympa"],
    notify  => Service["sympa"],
  }

  service { 'sympa':
    ensure  => running,
    enable  => true,
    #status  => '[ $(pgrep -f "sympa/bin/(sympa|archived|task_manager|bounced).pl$" | wc -l) == 4 ]', # this seems broken in puppet 0.25.
    hasstatus => false,
    require => [File["/etc/sympa/sympa.conf"], Package['libdbd-pg-perl']],
  }

  collectd::config::plugin { 'monitor sympa':
    plugin   => 'processes',
    settings => 'ProcessMatch "sympa" "/usr/bin/perl.*/usr/lib/sympa"',
  }

}
