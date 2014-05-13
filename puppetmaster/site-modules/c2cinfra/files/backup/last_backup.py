#!/usr/bin/env python

import bernhard
import os, time
from sys import argv
from socket import gethostname

HOST   = gethostname()
SERVER = argv[1]
STATEFILE = '/var/backups/local.backup.timestamp'

c = bernhard.Client(SERVER)
event = {}
event['host'] = HOST
event['service'] = 'last successful backup time'
event['ttl'] = 7200
event['tags'] = ['backups']

if os.path.exists(STATEFILE):
  timediff = time.time() - os.stat(STATEFILE).st_mtime
  event['metric'] = int(timediff)

  if timediff < 0:
    event['state'] = 'critical'
    event['description'] = 'in the future, this is wrong!'
  elif 90000 < timediff < 180000: # 1d+1h, resp. 2d+2h
    event['state'] = 'warning'
    event['description'] = 'older than 1 day'
  elif timediff > 180000:
    event['state'] = 'critical'
    event['description'] = 'older than 2 days'
  else:
    event['state'] = 'ok'
    event['description'] = 'within last 24h'

else:
  event['description'] = 'no statefile found'
  event['state'] = 'critical'

c.send(event)
