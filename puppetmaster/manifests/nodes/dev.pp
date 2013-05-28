# VM
node 'dev' inherits 'base-node' {

  include '::nginx'
  include '::c2corg::trac'
  include '::c2corg::wikiassoce'

  include '::c2corg::devproxy::http'
  include '::c2corg::devproxy::https'

  include '::c2corg::devproxy::graphite'

  fact::register {
    'role': value => ['trac dev', 'wiki association', 'proxy environnements dev'];
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { [
    '/srv/trac',
    '/var/lib/dokuwiki/',
  ]: }

}
