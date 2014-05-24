# -*- coding: utf-8 -*-

# Import python libs
import salt.utils
import logging
import os.path

log = logging.getLogger(__name__)

def puppet_classes():
  classes_file = '/var/lib/puppet/state/classes.txt'

  if os.path.isfile(classes_file):
    fd = open(classes_file, 'r')
    classes = []

    for line in fd:
      classes.append(line.strip())
    fd.close()

    return {'puppet_classes': sorted(classes)}

  else:
    return {'puppet_classes': None}
