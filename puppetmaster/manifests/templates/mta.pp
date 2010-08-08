class mta {

  $postfix_relayhost = "googlemail.com"
  $root_mail_recipient = "marc.fournier@camptocamp.org"
  $postfix_smtp_listen = $hostname ? {
    'lists' => '0.0.0.0',
    default => "127.0.0.1",
  }

  include postfix::satellite

}
