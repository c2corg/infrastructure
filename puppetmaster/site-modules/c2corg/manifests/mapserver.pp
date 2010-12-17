class c2corg::mapserver inherits mapserver::debian {
  Package["libecw"] { ensure => absent }
}
