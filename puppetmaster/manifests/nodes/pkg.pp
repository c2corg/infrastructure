# VM - package repository
node 'pkg' inherits 'base-node' {

  include c2corg::reprepro

  c2corg::backup::dir { "/srv/deb-repo/": }

}
