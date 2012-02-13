class haproxy::collectd::typesdb {

  $typesdb = "/usr/share/collectd/haproxy.db"

  collectd::plugin { "haproxy-typesdb":
    content => "TypesDB \"${typesdb}\"\n",
  }

  file { "haproxy collectd types":
    path    => $typesdb,
    content => "haproxy   stot:COUNTER:0:U   bin:COUNTER:0:U   bout:COUNTER:0:U   econ:COUNTER:0:U   eresp:COUNTER:0:U   hrsp_1xx:COUNTER:0:U   hrsp_2xx:COUNTER:0:U   hrsp_3xx:COUNTER:0:U   hrsp_4xx:COUNTER:0:U   hrsp_5xx:COUNTER:0:U   hrsp_other:COUNTER:0:U\n",
  }

}
