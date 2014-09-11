#!/usr/bin/env python

import riemann_client.client
from riemann_client.transport import TCPTransport
from subprocess import Popen, PIPE
from sys import argv
import re

SERVER = argv[1]
TTL    = int(argv[2])
ZPOOL  = argv[3]

zpool_list = [ '/sbin/zpool', 'list', '-H', '-o', 'health', ZPOOL]
zpool_status = [ '/sbin/zpool', 'status', '-x', ZPOOL]

def check(cmd, match):
  with Popen(cmd, stdout=PIPE, shell=False).stdout as stdout:
    output = stdout.readlines()
    if re.match(match, output[0]):
      state = "ok"
    else:
      state = "critical"
    description = ''.join(output)
    service = service="%s %s: %s" % (cmd[0], cmd[1], ZPOOL)
    client.event(service=service, state=state, description=description, tags=["raid"], ttl=TTL)

with riemann_client.client.Client(TCPTransport(SERVER, 5555)) as client:
  check(zpool_list, '^ONLINE$')
  check(zpool_status, '^pool.+is healthy$')

