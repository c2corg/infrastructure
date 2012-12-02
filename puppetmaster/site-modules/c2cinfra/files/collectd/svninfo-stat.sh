#!/bin/sh

#HOME=$(getent passwd $(whoami) | cut -d: -f6) # dumb svn needs to create $HOME/.subversion

host="${COLLECTD_HOSTNAME:-localhost}"
pause=300

while getopts "i:h:p:d:" c; do
  case $c in
    i)  instance=$OPTARG;;
    h)  host=$OPTARG;;
    p)  pause=$OPTARG;;
    d)  dir=$OPTARG;;
    *)  echo "Usage: $0 -d <dir> [-i <instance>] [-h <hostname>] [-p <seconds>]";;
  esac
done

while [ $? -eq 0 ]; do
  time="$(date +%s)"
  rev=$(svn --config-dir /etc info ${dir} | grep Revision | cut -f2 -d' ')
  echo "PUTVAL ${host}/svninfo/gauge-${instance:-default} interval=${pause} ${time}:${rev:-0}"
  sleep $pause
done
