# VM
node 'dev' inherits 'base-node' {

  include c2corg::trac
  include c2corg::wikiassoce

  include c2corg::devproxy::http
  include c2corg::devproxy::https

  fact::register {
    'role': value => ['trac dev', 'wiki association', 'proxy environnements dev'];
    'duty': value => 'prod';
  }

  c2corg::backup::dir { [
    "/srv/trac",
    "/srv/svn",
    "/var/lib/dokuwiki/",
  ]: }

}
