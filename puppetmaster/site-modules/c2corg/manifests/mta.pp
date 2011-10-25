class c2corg::mta {

  $postfix_relayhost = "googlemail.com"
  $root_mail_recipient = "marc.fournier@camptocamp.org"

  if ($hostname != 'lists') {
    include postfix::satellite
  }


}
