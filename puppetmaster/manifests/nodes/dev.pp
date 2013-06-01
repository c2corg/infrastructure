# VM
node 'dev' inherits 'base-node' {

  include '::nginx'
  include '::c2corg::trac'
  include '::c2corg::wikiassoce'

  include '::c2corg::devproxy'
  include '::c2corg::devproxy::graphite'
  include '::c2corg::devproxy::dashboard'
  include '::c2corg::devproxy::trac'
  include '::c2corg::devproxy::wikiassoce'

  fact::register {
    'role': value => ['trac dev', 'wiki association', 'proxy environnements dev'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { [
    '/srv/trac',
    '/var/lib/dokuwiki/',
  ]: }

}
