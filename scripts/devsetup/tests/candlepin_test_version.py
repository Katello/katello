#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import simplejson
from utils import *


#-------------------------------------------------------------------------------
def main(argv):
	#test if candlepin version is higher or equal than required
	
	p = os.popen('curl -k https://localhost:8443/candlepin/status 2> /dev/null')
	response = p.readline()
	p.close()
	
	#load required version from config
	cfg = Config(sys.path[0]+'/../config.cfg')
	requiredVersion = cfg.getValue('candlepin_version')
	
	
	try:
		candlepinVersion = simplejson.loads(response)['version']
	except:
		msgFail('candlepin is not responding')
		return 1
	
	msgOK('candlepin responding')
	if candlepinVersion >= requiredVersion:
		msgOK('candlepin '+ candlepinVersion)
		return 0
	else:
		msgFail('candlepin version '+ candlepinVersion +' ( required '+ requiredVersion +' )')
		return 1



#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
