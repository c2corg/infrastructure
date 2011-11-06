define c2corg::backup::dir {

  include c2corg::backup

  $fname = regsubst($name, "\/", "_", "G")

  if $backupkey {
    common::concatfilepart { "include $fname in backups":
      file    => "/root/.backups.include",
      content => "${name}\n",
      manage  => true,
      before  => Cron["rsync important stuff to backup server"],
    }
  }
}
