class c2corg::database::dev inherits c2corg::database::common {

  include c2corg::password

  Postgresql::User["${c2corg::password::www_db_user}"] {
    password => $c2corg::password::dev_db_pass,
  }

}
