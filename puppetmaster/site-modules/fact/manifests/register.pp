define fact::register($value) {

  file { "/etc/facter/facts.d/${name}.json":
    ensure  => present,
    content => inline_template('<%= { name, value.is_a?(Array) ? value.join(",") : value }.to_json %>'),
  }
}
