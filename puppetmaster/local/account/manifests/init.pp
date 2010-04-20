class account {

  account::user { "marc@root": user => "marc", account => "root" }

  @account::user { "marc": account => "marc" }
}

define account::user ($ensure=present, $user=$name, $account) {

  if !defined(User[$account]) {
    user { $account:
      ensure => $ensure,
    }
  }

  case $user {
    "marc": {
      ssh_authorized_key { "$name on $account":
        ensure  => $ensure,
        user    => $account,
        type    => "rsa",
        key     => "AAAAB3NzaC1yc2EAAAABIwAAAQEAuzVRsZMCL1CHqcB5tBVATgRucCaMVpQz5qKO8RAlSwpRod8DYBBMxWpolclxyX+9qHXLiwIWv/Ourld/HrLdbHOpiQ/QAZzZoEOrIQ+hT/iRnlA4Pdub7Ep2Y2AO3eGH8kJn8vl8tkAiey577dfmhYo9LTJQD6csyLEmmnoef/Rn9qWXrUTLF5/1sobtuQ1jkB1qUSG0yjrRTuyLh9/pv6xJgTpQNP5x9ok7MsRrPaZZ5Oyzt0JRNsKY5LpgNForXCm5gsGk+qfoET8zUZ8YUEue8h7zE5WShZNhAnN43EaxxGoBkqQDcnSygJVetfRlwt9JHt4xPrdFJDulvCun+w==",
        require => User[$account],
      }
    }
  }

}
