class graphite::webapp {

  include graphite

  exec { "install graphite webapp":
    command => "python setup.py install --prefix /opt/graphite --install-lib /opt/graphite/webapp",
    cwd     => "/usr/src/graphite",
    creates => "/opt/graphite/webapp",
    require => Vcsrepo["/usr/src/graphite"],
  }

}
