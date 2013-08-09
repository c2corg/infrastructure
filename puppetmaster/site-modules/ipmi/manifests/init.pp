class ipmi {

  include ipmi::client

  kmod::load { ['ipmi_devintf', 'ipmi_si']:
    before => [Service['ipmievd'], Collectd::Plugin['ipmi']],
    notify => Service['collectd'],
  }

  etcdefault { 'enable ipmievd service':
    key    => 'ENABLED',
    file   => 'ipmievd',
    value  => 'true',
    before => Service['ipmievd'],
  }

  etcdefault { 'configure ipmievd for polling':
    key    => 'IPMIEVD_OPTIONS',
    file   => 'ipmievd',
    value  => '"sel daemon"',
    notify => Service['ipmievd'],
  }

  service { 'ipmievd':
    ensure    => 'running',
    enable    => true,
    hasstatus => false,
    require   => Package['ipmitool'],
  }

  collectd::plugin { 'ipmi': }

  collectd::config::chain { 'RemoveIpmiSpecialChars':
    type     => 'precache',
    targets  => ['replace'],
    matches  => ['regex'],
    settings => '
<Rule "remove_ipmi_special_chars">
  <Match "regex">
    Plugin "^ipmi$"
  </Match>
  <Target "replace">
    TypeInstance "\\(" ""
    TypeInstance "\\)" ""
  </Target>
</Rule>
',
  }

  augeas { 'remove module ipmi_devintf':
    incl    => '/etc/modprobe.d/modprobe.conf',
    lens    => 'Modprobe.lns',
    changes => "rm install[. = 'ipmi_devintf']",
    onlyif  => "match install[. = 'ipmi_devintf'] size > 0",
    before => Kmod::Load['ipmi_devintf'],
  }

  augeas { 'remove module ipmi_si':
    incl    => '/etc/modprobe.d/modprobe.conf',
    lens    => 'Modprobe.lns',
    changes => "rm install[. = 'ipmi_si']",
    onlyif  => "match install[. = 'ipmi_si'] size > 0",
    before => Kmod::Load['ipmi_si'],
  }

}
