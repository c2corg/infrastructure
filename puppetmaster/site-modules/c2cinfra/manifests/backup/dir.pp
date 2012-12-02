define c2cinfra::backup::dir {

  include c2cinfra::backup

  $fname = regsubst($name, '\/', '_', 'G')

  if $::backupkey {
    concat::fragment { "include_${fname}_in_backups":
      target  => "/root/.backups.include",
      content => "${name}\n",
      before  => Cron["rsync important stuff to backup server"],
    }
  }
}
