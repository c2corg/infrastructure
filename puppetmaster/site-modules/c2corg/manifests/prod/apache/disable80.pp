class c2corg::prod::apache::disable80 inherits apache::base {
  Apache::Listen["80"] { ensure => absent }
}
