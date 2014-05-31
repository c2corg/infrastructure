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

cciss = ['/usr/bin/cciss_vol_status', '/dev/cciss/c0d0']

output = Popen(cciss, stdout=PIPE, shell=False).stdout

for line in output:
  event = {}
  event['host'] = HOST
  event['ttl'] = TTL
  event['tags'] = ['raid']

  if re.match('.+:\s+ok.*$', line, flags=re.IGNORECASE):
    event['state'] = 'ok'
  else:
    event['state'] = 'critical'

  event['service'] = re.sub('\s+\(.+?\)|\s+status:.*|/dev/cciss/', '', line.strip())
  event['description'] = line.strip()

  c.send(event)

