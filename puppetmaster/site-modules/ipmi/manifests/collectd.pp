class ipmi::collectd {

  collectd::plugin { 'ipmi':
    require => Class['ipmi::setup'],
  }

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

}
