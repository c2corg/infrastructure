# VM
node 'dev' inherits 'base-node' {

  include '::nginx'
  include '::c2cinfra::trac'
  include '::c2cinfra::wikiassoce'

  include '::c2cinfra::devproxy'
  include '::c2cinfra::devproxy::graphite'
  include '::c2cinfra::devproxy::inventory'
  include '::c2cinfra::devproxy::trac'
  include '::c2cinfra::devproxy::wikiassoce'

  fact::register {
    'role': value => ['trac dev', 'wiki association', 'proxy environnements dev'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { [
    '/srv/trac',
    '/var/lib/dokuwiki/',
  ]: }

}
