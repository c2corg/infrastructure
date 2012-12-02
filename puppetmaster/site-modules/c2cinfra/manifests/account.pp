class c2cinfra::account {

  c2cinfra::account::user { "marc@root": user => "marc", account => "root" }

  @c2cinfra::account::user {
    "marc": user => "marc", account => "marc",
      groups => ["adm", "www-data"];

    "alex": user => "alex", account => "alex",
      groups => ["adm", "www-data"];

    "gottferdom": user => "gottferdom", account => "gottferdom",
      groups => ["adm", "www-data"];

    "xbrrr": user => "xbrrr", account => "xbrrr",
      groups => ["adm", "www-data"];

    "gerbaux": user => "gerbaux", account => "gerbaux",
      groups => ["adm", "www-data"];

    "jose": user => "jose", account => "jose",
      groups => ["adm", "www-data"];

    "bubu": user => "bubu", account => "bubu",
      groups => ["adm", "www-data"];

    "saimon": user => "saimon", account => "saimon",
      groups => ["adm", "www-data"];

    "c2corg": user => "c2corg", account => "c2corg",
      groups => ["adm", "www-data"];

    "vagrant": user => "vagrant", account => "vagrant",
      groups => ["admin"];

  }
}
