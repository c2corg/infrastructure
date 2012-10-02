define etcdefault($ensure=present, $file, $key, $value) {

  $changes = $ensure ? {
    present => "set ${key} ${value}",
    absent  => "rm ${key}",
  }

  augeas { "set /etc/default/${file} parameter '${key}' to '${value}'":
    lens    => 'Shellvars.lns',
    incl    => "/etc/default/${file}",
    changes => $changes,
  }
}
