class c2cinfra::collectd::plugin::postfix {

  collectd::config::plugin { 'postfix logs plugin':
    plugin   => 'tail',
    settings => template('c2cinfra/collectd/postfix.conf'),
  }
}
