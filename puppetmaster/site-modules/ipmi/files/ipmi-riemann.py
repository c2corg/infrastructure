#!/usr/bin/env python

import bernhard
from subprocess import Popen, PIPE
from csv import DictReader
from socket import gethostname
from sys import argv

HOST   = gethostname()
SERVER = argv[1]
TTL    = int(argv[2])

c = bernhard.Client(SERVER)

ipmi_cmd = [
  '/usr/sbin/ipmi-sensors',
  '--output-sensor-state',
  '--ignore-not-available-sensors',
  '--comma-separated-output',
  '--entity-sensor-names',
  '--non-abbreviated-units']

output = Popen(ipmi_cmd, stdout=PIPE, shell=False).stdout
csvreader = DictReader(output, delimiter=',', quotechar="'")
result = [ d.copy() for d in csvreader ]

for probe in result:
# ID,Name,Type,State,Reading,Units,Event
  event = {}
  event['host'] = HOST
  event['ttl'] = TTL
  event['tags'] = ['ipmi']

  event['service'] = probe['Name']

  if probe['State'] == 'Nominal':
    event['state'] = 'ok'
  elif probe['State'] == 'N/A':
    event['state'] = 'ok'
  elif probe['State'] == 'Critical':
    event['state'] = 'critical'
  else:
    event['state'] = probe['State']

  event['attributes'] = {'type': probe['Type']}
  event['description'] = probe['Event']

  if probe['Reading'] != 'N/A':
    event['metric'] = float(probe['Reading'])
    event['attributes']['units'] = probe['Units']

  c.send(event)

