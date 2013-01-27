class c2corg::prod::collectd::webserver {

  collectd::config::plugin { 'monitor apache2 process':
    plugin   => 'processes',
    settings => 'Process apache2',
  }

  # Solution transitoire. Il faudrait trouver une solution qui s'intègre plus
  # intelligemment dans l'infra, peut-être au niveau de haproxy ou varnish.
#  collectd::plugin { "httplogsc2corg":
#    source => "puppet:///modules/c2corg/collectd/httplogsc2corg.conf",
#  }

}
