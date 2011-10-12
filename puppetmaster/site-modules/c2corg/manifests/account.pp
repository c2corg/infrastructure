class c2corg::account {

  c2corg::account::user { "marc@root": user => "marc", account => "root" }

  @c2corg::account::user {
    "marc": user => "marc", account => "marc";
    "alex": user => "alex", account => "alex";
    "gottferdom": user => "gottferdom", account => "gottferdom";
    "xbrrr": user => "xbrrr", account => "xbrrr";
    "gerbaux": user => "gerbaux", account => "gerbaux";
    "c2corg": user => "c2corg", account => "c2corg";
  }
}

define c2corg::account::user ($ensure=present, $user, $account) {

  if !defined(User[$account]) {
    user { $account:
      ensure => $ensure,
      shell  => "/bin/bash",
      managehome => true,
    }
  }

  case $user {
    "marc": {
      c2corg::sshuserkey { "$name on $account":
        account => $account,
        user    => $user,
        type    => "rsa",
        key     => "AAAAB3NzaC1yc2EAAAABIwAAAQEAuzVRsZMCL1CHqcB5tBVATgRucCaMVpQz5qKO8RAlSwpRod8DYBBMxWpolclxyX+9qHXLiwIWv/Ourld/HrLdbHOpiQ/QAZzZoEOrIQ+hT/iRnlA4Pdub7Ep2Y2AO3eGH8kJn8vl8tkAiey577dfmhYo9LTJQD6csyLEmmnoef/Rn9qWXrUTLF5/1sobtuQ1jkB1qUSG0yjrRTuyLh9/pv6xJgTpQNP5x9ok7MsRrPaZZ5Oyzt0JRNsKY5LpgNForXCm5gsGk+qfoET8zUZ8YUEue8h7zE5WShZNhAnN43EaxxGoBkqQDcnSygJVetfRlwt9JHt4xPrdFJDulvCun+w==",
        require => User[$account],
      }
    }

    "alex": {
      c2corg::sshuserkey { "$name on $account":
        account => $account,
        user    => $user,
        type    => "dss",
        key     => "AAAAB3NzaC1kc3MAAACBAPxBNSR4YKDNmE3Mob7SInQOLg2Qr/ZLUqAwyXxYTagx9itC1fSuG2BZzTUF61iF3uQN57bzaduq9PY4MmkgbtW2AdDVeV3mbh5L4AxBWGJx/6rp7mJeRkVt9ve3P4APton8djhoDY1YbwzusVALtZlvNDnO3Y9skgte0GJ4en/3AAAAFQCMCrNEPeIfTDlLAJHqVwxR28aKHwAAAIEArJwQx4G5K3LiK+SltbzOR+hwmJARADOVy58/TR+q4ITjLQVWQ/iMov0S6KCXv/yJ4DtombwkVFyTkVbMN6mh9PpOixlAs7Azyam8OeP94JF/g6jgAylZa0OEdzSPeKnD3dYrr3s187oKZ4imuhPKQabMQqu/0eB8QS/kZfpRv00AAACBAKkhTfegNtwTq5hPKRfLUr/vZkpLriW/vw8lFaTC+x6QesLDxX+JaE0c/+DjKtxQHhFeQCTTuLKwr7zR5Ejbtz64ssAMiAeZEO/i3WmywHTwxe4BisGC+gaGLr9u45ml3zskquc1oXEiRdi6ttKZAfb7TetjOSC1oCzRoZMoqZTe",
        require => User[$account],
      }
    }

    "gottferdom": {
      c2corg::sshuserkey { "$name on $account":
        account => $account,
        user    => $user,
        type    => "dss",
        key     => "AAAAB3NzaC1kc3MAAACBAKaOeR4EnmGLdZyRvbprhZhJv74J+RHBQbtU6O9+64WW7veCPxMt7KaluKxbNxJzGB5lXnRyiLQoaoRE/kjIBq7g/5NDN5OoypevmqTniRO2qhUINs6qNXOsXmroA4XtORYISU8GHXYNxjXPT8eTd9YxuITH8c/7VfeG03l3N4ShAAAAFQCyxcbtPPmEno6XqPQMOM8DVE/bsQAAAIEAnSZOHmOnQ8ByOU2fFfjpC1DRIfV9lGU2xSI3nibcdZGwGGj7RGRNKMCvAqxLSrmpVWe0Tq1Ae5l4IGtg6BoKZP41/MYAYhmWxQRwJ/x8ErQub7RJiHS4e3y/n/hK9tiR0JfzL8Qy6vL1xv6/USDbE4Q09OyriGng954/3SOuYREAAACBAJqXqWMNfy93lvIzjUsYdz8wOr2iW1ur+EHdZbh37Cnf/MD0Ef5OYK0n5ZAiqWl3abZSMg2shnULMyI+bbY6Cr9g22e2fCrKrx7Sr4IzvzADxQDj7JHgiXTPCZQyPz/nlUsVSRezvO/HfzAxjNg1zLwy2WlgGkmmS+NvcKHZwUNP",
        require => User[$account],
      }
    }

    "xbrrr": {
      c2corg::sshuserkey { "$name on $account":
        account => $account,
        user    => $user,
        type    => "dss",
        key     => "AAAAB3NzaC1kc3MAAACBAPU0k5Lg0KFgzjkiAZEoYEGS4bYf9ASoE4D3ffuafBCdD/90jKxu4H10lveEOJSKGMYOtmgU3+bzywTd/p2n6UwczjLPJ4Dy6x1f7Byd/onC77/kAWiztRPY778er0NdslnFA9anKwPSuqoCv9WVYhdEh2Cq2dCFGvesxeesataXAAAAFQC2WR4aRdlit5kU/12jXeVxhrESXwAAAIEA8Eu2i0S20um6Otx4Yo5WThHG82LTrnL7HjscWVEKGL3ICqyqt6StT4nT8TrOS7xHGXPgUpLXTkI4zThM0rhTBOlRPszsbS8nl8CtU5wtIUoP0W2bbPWdLokPI80lLC1Dc77BydJD1kXVQlwoeYgOR4UILlZPb988J4Q1ON9TQT0AAACAcFvlhAD82Eer5SuWYefgaSay2M+/BqyEE2hWgt3eBv8xeU/5vI6NqvXJG0OGCPZQ6YLVbZlvdh86YkrvE6HjqgrG2kFUUokG8vy3iYrRLeJUGJ5JnB8EHUCLsfwZNU4x6+YY34Nnv9npd3zDDSjiwHxx/gfqr8uCQNlZCmmhEk8=",
        require => User[$account],
      }
    }

    "gerbaux": {
      c2corg::sshuserkey { "$name on $account":
        account => $account,
        user    => $user,
        type    => "dss",
        key     => "AAAAB3NzaC1kc3MAAACBAJW+dnvqotAaaWmF72JDDLccYPK6NIRNK9m7hCPOa1iYXronIV3YPw0wlx7HOJkHuiVinD7GwlUM3iIyXUvAbWjiRVfUD/r7kIXZxTaNpT+YM+tPB9q2o33LMtgHb9iNLwiKsLycrbCZ0Wp3R9v714c5GqV1JcG6/lRoYJ3KwNKdAAAAFQCs6gw1fNQudexweUGmXJJBiydxIwAAAIAB4Zn9A/jT3ZpNShkX/nNp7yXVr6Nftv1iopMMsfWzyxnu8EDdtmACLaTuRp/PBHi6sEAQHn0b9f6yVzD4lE4yOIl3wYPjeeQz3zoYdYoBoqh4RsTZbb7Wh1M4zH7PK1UqyS6r7q2gtmr/jKdINh1PTBxY+K8ni0vSPd2Tk2hLawAAAIAfIPCFfEuXgGbeq7EPapUc6D5jPzaKBIQIto3d5AdaV3mxPyboDteQ+UP57t5+8TQv1cb3J8+J9v+SVYP4y+zQru091dXcLqMgHrU7Cbc+frpIkiAQTorW3GFvlZrXgt0YtT0XuJd3Ak6V+HvTR4ANtFPMF20I0itkBEl81HnOCQ==",
        require => User[$account],
      }
    }

  }
}
