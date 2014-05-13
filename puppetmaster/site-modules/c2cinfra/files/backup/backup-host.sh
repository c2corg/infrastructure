#!/bin/sh

if test $# -ne 2; then
  echo "usage: $0 <backup dest> <riemann host>"
  exit 1
fi

rsync_dest="${1}"
riemann_url="http://${2}:5556/events"
host=$(hostname -s)
lockfile="/var/run/backup.lock"
ttl=124800 # 48h

function _msg() {
  echo "$1"
  curl -s -X POST -m 30 -d "{\"host\":\"${host}\",\"service\":\"offsite backup exit status\",\"state\":\"${2}\",\"description\":\"${1}\",\"ttl\":${ttl},\"tags\":[\"backups\"]}" $riemann_url > /dev/null
}

if test -f $lockfile; then
  _msg "lockfile exists, skipping backup" "critical"
  exit 1
fi

if ! touch $lockfile; then
  _msg "unable to create lockfile, skipping backup" "critical"
  exit 1
fi

timeout 23h rsync --rsh='ssh -i /root/.backupkey' --archive --numeric-ids \
  --delete --compress --relative --quiet $(cat /root/.backups.include) \
  "${rsync_dest}"

if test 0 -ne $?; then
  _msg "rsync backup failed, check logs" "critical"
else
  _msg "backup successful" "ok" > /dev/null
  touch /var/backups/local.backup.timestamp
fi

rm -f $lockfile
