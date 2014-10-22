#!/usr/bin/env python

import bernhard
import os, time
from datetime import datetime
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
  lastbackup = os.stat(STATEFILE).st_mtime
  timediff = time.time() - lastbackup

  if timediff < 0:
    event['state'] = 'critical'
    description = 'in the future, this is wrong!'
  elif 90000 < timediff < 180000: # 1d+1h, resp. 2d+2h
    event['state'] = 'warning'
    description = 'older than 1 day'
  elif timediff > 180000:
    event['state'] = 'critical'
    description = 'older than 2 days'
  else:
    event['state'] = 'ok'
    description = 'within last 24h'

    event['description'] = "%s: %s" % (description, datetime.utcfromtimestamp(lastbackup).strftime("%Y-%m-%d %H:%m:%S"))


else:
  event['description'] = 'no statefile found'
  event['state'] = 'critical'

c.send(event)
