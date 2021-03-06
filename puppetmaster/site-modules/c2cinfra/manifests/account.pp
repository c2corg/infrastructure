class c2cinfra::account {

  # users which have root access on every machine.
  c2cinfra::account::user { 'marc@root':  user => 'marc',  account => 'root' }
  c2cinfra::account::user { 'xbrrr@root': user => 'xbrrr', account => 'root' }

  @c2cinfra::account::user {
    "marc": user => "marc", account => "marc",
      tag    => ['trempoline','docker-compose'],
      groups => ["adm", "users", "www-data"];

    "alex": user => "alex", account => "alex",
      tag    => ['trempoline','docker-compose'],
      groups => ["adm", "users", "www-data"];

    "gottferdom": user => "gottferdom", account => "gottferdom",
      tag    => ['trempoline','docker-compose'],
      groups => ["adm", "users", "www-data"];

    "xbrrr": user => "xbrrr", account => "xbrrr",
      tag    => ['trempoline','docker-compose'],
      groups => ["adm", "users", "www-data"];

    "gerbaux": user => "gerbaux", account => "gerbaux",
      groups => ["adm", "users", "www-data"];

    "jose": user => "jose", account => "jose",
      groups => ["adm", "users", "www-data"];

    "bubu": user => "bubu", account => "bubu",
      groups => ["adm", "users", "www-data"];

    "saimon": user => "saimon", account => "saimon",
      tag    => ['trempoline'],
      groups => ["adm", "users", "www-data"];

    "stef74": user => "stef74", account => "stef74",
      tag    => ['trempoline'],
      groups => ["adm", "users", "www-data"];

    "amorvan": user => "amorvan", account => "amorvan",
      tag    => ['docker-compose'],
      groups => ["adm", "users"];

    "tsauerwein": user => "tsauerwein", account => "tsauerwein",
      tag    => ['docker-compose'],
      groups => ["adm", "users"];

    "c2corg": user => "c2corg", account => "c2corg",
      groups => ["adm", "users", "www-data"];

    "vagrant": user => "vagrant", account => "vagrant";

  }
}
