class c2corg::prod::collectd::webserver {

  collectd::plugin { "processes":
    content => '# Avoid LoadPlugin as processes is already loaded elsewhere
<Plugin processes>
  Process "apache2"
</Plugin>
',
  }

  # Solution transitoire. Il faudrait trouver une solution qui s'intègre plus
  # intelligemment dans l'infra, peut-être au niveau de haproxy ou varnish.
#  collectd::plugin { "httplogsc2corg":
#    source => "puppet:///modules/c2corg/collectd/httplogsc2corg.conf",
#  }

}
