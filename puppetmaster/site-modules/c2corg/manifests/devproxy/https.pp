class c2corg::devproxy::https {

  file { "/var/www/dev.camptocamp.org/private/dashboard-AAA-header.part":
    content => "<html><body>\n",
    notify  => Exec["aggregate dashboard snippets"],
  }

  file { "/var/www/dev.camptocamp.org/private/dashboard-ZZZ-footer.part":
    content => "</body></html>\n",
    notify  => Exec["aggregate dashboard snippets"],
  }

  exec { "aggregate dashboard snippets":
    command     => "cat /var/www/dev.camptocamp.org/private/dashboard-* > /var/www/dev.camptocamp.org/private/dashboard.html",
    refreshonly => true,
  }

  # list of facts to show in inventory
  $facts = ['role', 'lsbdistcodename', 'virtual', 'datacenter', 'interfaces']

  $nodes = pdbquery('nodes', ['=', ['node', 'active'], true ])
  $res = pdbfactquery($nodes)

  file { '/var/www/dev.camptocamp.org/htdocs/inventory.html':
    content => template('c2cinfra/dashboard/inventory.erb'),
  }

  file { "/var/www/dev.camptocamp.org/private/dashboard-inventory.part":
    content => "<li><a href='https://dev.camptocamp.org/inventory.html'>inventory</a></li>\n",
    notify  => Exec["aggregate dashboard snippets"],
  }

}
