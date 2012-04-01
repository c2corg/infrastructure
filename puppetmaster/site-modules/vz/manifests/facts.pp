class vz::facts {
  if ($::virtual == 'openvzve') {
    File <<| tag == "openvzfacts-${::fqdn}" |>>
  }
}
