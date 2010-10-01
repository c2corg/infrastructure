class account {

  account::user { "marc@root": user => "marc", account => "root" }

  @account::user { "marc": account => "marc" }
  @account::user { "alex": account => "alex" }
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

    "alex": {
      ssh_authorized_key { "$name on $account":
        ensure  => $ensure,
        user    => $account,
        type    => "dsa",
        key     => "AAAAB3NzaC1kc3MAAACBAPxBNSR4YKDNmE3Mob7SInQOLg2Qr/ZLUqAwyXxYTagx9itC1fSuG2BZzTUF61iF3uQN57bzaduq9PY4MmkgbtW2AdDVeV3mbh5L4AxBWGJx/6rp7mJeRkVt9ve3P4APton8djhoDY1YbwzusVALtZlvNDnO3Y9skgte0GJ4en/3AAAAFQCMCrNEPeIfTDlLAJHqVwxR28aKHwAAAIEArJwQx4G5K3LiK+SltbzOR+hwmJARADOVy58/TR+q4ITjLQVWQ/iMov0S6KCXv/yJ4DtombwkVFyTkVbMN6mh9PpOixlAs7Azyam8OeP94JF/g6jgAylZa0OEdzSPeKnD3dYrr3s187oKZ4imuhPKQabMQqu/0eB8QS/kZfpRv00AAACBAKkhTfegNtwTq5hPKRfLUr/vZkpLriW/vw8lFaTC+x6QesLDxX+JaE0c/+DjKtxQHhFeQCTTuLKwr7zR5Ejbtz64ssAMiAeZEO/i3WmywHTwxe4BisGC+gaGLr9u45ml3zskquc1oXEiRdi6ttKZAfb7TetjOSC1oCzRoZMoqZTe",
        require => User[$account],
      }
    }
  }

}
