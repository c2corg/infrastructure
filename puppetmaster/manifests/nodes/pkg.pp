# VM
node 'pkg' inherits 'base-node' {

  include c2corg::reprepro

  fact::register { 'role': value => 'repository de paquets' }

  c2corg::backup::dir { "/srv/deb-repo/": }

}
