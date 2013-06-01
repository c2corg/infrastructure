class c2cinfra::devproxy::inventory {

  # list of facts to show in inventory
  $facts = ['role', 'lsbdistcodename', 'virtual', 'datacenter', 'interfaces']

  $nodes = pdbquery('nodes', ['=', ['node', 'active'], true ])
  $res = pdbfactquery($nodes)

  file { '/srv/dev.camptocamp.org/htdocs/inventory.html':
    content => template('c2cinfra/dashboard/inventory.erb'),
  }

}
