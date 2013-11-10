define mknod($ensure='present', $type, $major, $minor) {
  case $ensure {
    'present': {
      exec { "mknod /dev/${name} $type $major $minor":
        unless => "test -e /dev/${name}",
      }
    }
    'absent': {
      file { "/dev/${name}": ensure => absent }
    }
  }
}
