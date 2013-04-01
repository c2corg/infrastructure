class c2corg::database::dev inherits c2corg::database::common {

  $www_db_user = hiera('www_db_user')

  Postgresql::User[$www_db_user] {
    password => hiera('dev_db_pass'),
  }

  if str2bool($::vagrant) {

    Postgresql::Hba['access for www user to c2corg db'] {
      address  => '10.0.0.0/8',
    }

    Postgresql::Hba['access for www user to metaengine db'] {
      address  => '10.0.0.0/8',
    }
  }

}
