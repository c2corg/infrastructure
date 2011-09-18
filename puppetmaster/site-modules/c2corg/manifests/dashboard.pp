class c2corg::dashboard {

  include apache::ssl

  apache::vhost-ssl { "admin-backends":
    aliases => ["128.179.66.13"],
    certcn  => "128.179.66.13",
    sslonly => true,
    ensure  => absent,
  }

}
