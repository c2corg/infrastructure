import "templates/*.pp"
import "nodes.pp"
import "common"

filebucket { main: server => $puppet_server }

Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin" }

File {
  backup => main,
  ignore => '.svn',
  owner  => root,
  group  => root,
}

Package {
  require => Exec["apt-get_update"],
}
