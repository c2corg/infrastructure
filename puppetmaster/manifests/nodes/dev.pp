# VM
node 'dev' {

  include c2cinfra::common
  include '::nginx'
  include '::c2cinfra::trac'
  include '::c2cinfra::wikiassoce'
  include '::puppet::board'

  include '::c2cinfra::devproxy'
  include '::c2cinfra::devproxy::graphite'
  include '::c2cinfra::devproxy::inventory'
  include '::c2cinfra::devproxy::trac'
  include '::c2cinfra::devproxy::wikiassoce'
  include '::c2cinfra::devproxy::puppetboard'

  fact::register {
    'role': value => ['trac dev', 'wiki association', 'proxy dev stuff'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { [
    '/srv',
    '/var/lib/dokuwiki/',
  ]: }

}
