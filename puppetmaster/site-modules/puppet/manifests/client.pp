class puppet::client {

  # undo workaround for expired release files in snapshot.debian.org
  apt::conf { "90snapshot-validity":
    ensure  => present,
    content => 'Acquire::Check-Valid-Until "true";',
  }

  apt::preferences { "puppet-packages_from_c2corg_repo":
    package  => "puppet puppetmaster puppetmaster-common puppet-common vim-puppet puppetdb puppetdb-terminus",
    pin      => "release l=C2corg, a=${::lsbdistcodename}",
    priority => "1010",
  }

  apt::preferences { "facter_from_c2corg_repo":
    package  => "facter",
    pin      => "release l=C2corg, a=${::lsbdistcodename}",
    priority => "1010",
  }

  if $::lsbdistcodename == 'squeeze' {
    apt::preferences { "augeas_from_bpo":
      package  => "libaugeas0 augeas-lenses augeas-tools",
      pin      => "release a=${::lsbdistcodename}-backports",
      priority => "1010",
    }
  }

  package { ["puppet", "facter"]:
    ensure  => present,
  }

  service { 'puppet':
    ensure    => stopped,
    enable    => false,
    hasstatus => true,
    require   => [Package['puppet'], Etcdefault['enable puppet at boot']],
  }

  etcdefault { 'enable puppet at boot':
    file   => 'puppet',
    key    => 'START',
    value  => 'no',
  }

  cron { 'run puppet':
    command => '/usr/bin/puppet agent --onetime --logdest syslog',
    user    => 'root',
    minute  => fqdn_rand(59),
  }

  $agent = $::puppetversion ? {
    /^0\.2/ => 'puppetd',
    default => 'agent',
  }

  puppet::config {
    'main/server':         value => 'pm';
    'main/report_server':  value => 'pm';
    'main/report':         value => 'true';
    'main/pluginsync':     value => 'true';
    "${agent}/certname":   value => $::hostname;
  }

  augeas { "rm other puppet conf target":
    lens    => 'Puppet.lns',
    incl    => '/etc/puppet/puppet.conf',
    changes => $::puppetversion ? {
      /^0\.2/ => "rm agent",
      default => "rm puppetd",
    },
  }

  file { ["/etc/facter", "/etc/facter/facts.d"]:
    ensure  => directory,
    source  => "puppet:///c2corg/empty",
    recurse => true,
    purge   => true,
    force   => true,
  }

  # if datacenter fact is set, then pluginsync has successfully run at least
  # once.
  if ($::datacenter and $::hostname != "pm") {
    host { "pm.pse.infra.camptocamp.org":
      ip           => hiera('puppetmaster_host'),
      host_aliases => ["pm"],
    }
  }

  sudoers { 'puppet client':
    users => '%adm',
    type  => "user_spec",
    commands => [
      '(root) /usr/sbin/puppetd',
      '(root) /usr/bin/puppet agent *',
      '(root) /etc/init.d/puppet',
      '(root) /usr/sbin/invoke-rc.d puppet *',
    ],
  }

}
