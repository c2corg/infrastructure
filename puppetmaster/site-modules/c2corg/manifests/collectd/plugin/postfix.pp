class c2corg::collectd::plugin::postfix {

  collectd::plugin { "postfix":
    source => "puppet:///c2corg/collectd/postfix.conf",
  }
}
