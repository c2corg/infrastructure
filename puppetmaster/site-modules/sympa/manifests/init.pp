class sympa($dbhost, $dbport, $dbtype, $dbname, $dbuser, $dbpwd, $hname, $listmaster) {

  apt::preferences { "sympa_from_c2corg_repo":
    package  => "sympa",
    pin      => "release l=C2corg, a=${::lsbdistcodename}",
    priority => "1010",
    before   => Package["sympa"],
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

}
