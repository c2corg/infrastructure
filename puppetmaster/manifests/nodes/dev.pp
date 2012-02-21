# VM - misc dev/private ressources
node 'dev' inherits 'base-node' {

  include c2corg::trac
  include c2corg::wikiassoce

  include c2corg::devproxy::http
  include c2corg::devproxy::https

  c2corg::backup::dir { [
    "/srv/trac",
    "/srv/svn",
    "/var/lib/dokuwiki/",
  ]: }

}
