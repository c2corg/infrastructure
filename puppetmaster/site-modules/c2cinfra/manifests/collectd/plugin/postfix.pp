class c2cinfra::collectd::plugin::postfix {

  collectd::plugin { "postfix":
    source => "puppet:///modules/c2cinfra/collectd/postfix.conf",
  }
}
