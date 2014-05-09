# VM
node 'logstash' inherits 'base-node' {

  include '::logstash::server'
  include '::nginx'
  include '::c2corg::syslog::pgbadger'

  c2cinfra::backup::dir {
    ['/etc/logstash', '/srv/logs/postgresql/reports/' ]:
  }

}
