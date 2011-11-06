class c2corg::database::preprod inherits c2corg::database::common {

  include c2corg::password

  Postgresql::Hba["access for www user to c2corg db"] {
    address => '192.168.0.0/16',
  }

  Postgresql::Hba["access for www user to metaengine db"] {
    address => '192.168.0.0/16',
  }

  Postgresql::User["${c2corg::password::www_db_user}"] {
    password => $c2corg::password::preprod_db_pass,
  }

}
