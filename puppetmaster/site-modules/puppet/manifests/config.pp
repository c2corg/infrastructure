define puppet::config ($ensure=present, $value) {

  $changes = $ensure ? {
    present => "set ${name} '${value}'",
    absent  => "rm ${name}",
  }

  augeas { "set puppet config parameter '${name}' to '${value}'":
    lens    => 'Puppet.lns',
    incl    => '/etc/puppet/puppet.conf',
    changes => $changes,
    require => Package['puppet'],
  }
}
