#!/bin/sh

proxy='stats'
sock='/var/run/haproxy.sock'
host="$(hostname)"
pause=10

while getopts "x:h:p:s:" c; do
  case $c in
    x)  proxy=$OPTARG;;
    h)  host=$OPTARG;;
    p)  pause=$OPTARG;;
    s)  sock=$OPTARG;;
    *)  echo "Usage: $0 [ -x <proxy> ] [-h <hostname>] [-p <seconds>] [-s <sockfile>]";;
  esac
done

while [ $? -eq 0 ]; do
  time="$(date +%s)"
  echo 'show stat' | socat - UNIX-CLIENT:$sock \
  | while IFS=',' read pxname svname qcur qmax scur smax slim stot bin bout dreq dresp ereq econ eresp wretr wredis status weight act bck chkfail chdown lastchg downtime qlimit pid iid sid throttle lbtot tracked type rate rate_lim rate_max check_status check_code check_duration hrsp_1xx hrsp_2xx hrsp_3xx hrsp_4xx hrsp_5xx hrsp_other hanafail req_rate req_rate_max req_tot cli_abrt srv_abrt; do
    [ "$pxname" != "$proxy" ] && continue
    echo "PUTVAL ${host}/haproxy/haproxy-${pxname}_${svname} interval=${pause} ${time}:${stot:-0}:${bin:-0}:${bout:-0}:${econ:-0}:${eresp:-0}:${hrsp_1xx:-0}:${hrsp_2xx:-0}:${hrsp_3xx:-0}:${hrsp_4xx:-0}:${hrsp_5xx:-0}:${hrsp_other:-0}"
  done
  sleep $pause
done
