#!/usr/bin/env python

import bernhard
import re
from subprocess import Popen, PIPE
from socket import gethostname
from sys import argv

HOST   = gethostname()
SERVER = argv[1]
TTL    = int(argv[2])

c = bernhard.Client(SERVER)

megacli = [
  '/usr/sbin/megacli',
  '-LdPdInfo',
  '-a0',
  '-NoLog']

output = Popen(megacli, stdout=PIPE, shell=False).stdout

id = ''

for line in output:
  values = line.split(':', 1)

  if len(values) > 1:
    key = values[0].strip()
    val = values[1].strip()

    if re.match('^virtual\s+drive', key, flags=re.IGNORECASE):
      id = 'VD ' + val
    elif re.match('^drive.+pos', key, flags=re.IGNORECASE):
      id = 'PD ' + val

    if key in ['Firmware state', 'State', 'Media Error Count', 'Predictive Failure Count']:
      event = {}
      event['host'] = HOST
      event['ttl'] = TTL
      event['tags'] = ['raid']
      event['service'] = id + ' / ' + key

      if re.match('.+count$', key, flags=re.IGNORECASE):
        if not re.match('\d+', val):
          event['state'] = 'warning'
          event['description'] = val
        elif int(val) > 0:
          event['metric'] = int(val)
          event['state'] = 'warning'
        else:
          event['metric'] = int(val)
          event['state'] = 'ok'
      else:
        event['description'] = val
        if re.match('online|optimal', val, flags=re.IGNORECASE):
          event['state'] = 'ok'
        else:
          event['state'] = 'critical'

      #print event
      c.send(event)

