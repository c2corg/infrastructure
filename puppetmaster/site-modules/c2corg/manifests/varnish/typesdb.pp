class c2corg::varnish::typesdb {

  $typesdb = "/usr/share/collectd/varnish.db"

  collectd::plugin { "varnish-typesdb":
    content => "TypesDB \"${typesdb}\"\n",
  }

  file { "varnish collectd types":
    path    => $typesdb,
    content => "# file managed by puppet
#bytes     value:GAUGE:0:U
cache_operation   value:DERIVE:0:U
#cache_result    value:DERIVE:0:U
#connections   value:DERIVE:0:U
#http_requests   value:DERIVE:0:U
requests    value:GAUGE:0:U
#threads     value:GAUGE:0:U
#total_bytes   value:DERIVE:0:U
total_operations  value:DERIVE:0:U
#total_requests    value:DERIVE:0:U
total_sessions    value:DERIVE:0:U
total_threads   value:DERIVE:0:U
",
    notify => Service["collectd"],
  }

}
