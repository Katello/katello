#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import simplejson
from utils import *

# Sample output of the ping service:
#
#{
#"result":"fail",
#"status":{
#	"pulp":{
#		"result":"ok",
#		"duration_ms":"47"
#	},
#	"candlepin_auth":{
#		"result":"fail",
#		"message":"Connection refused - connect(2)"
#	},
#	"pulp_auth":{
#		"result":"ok",
#		"duration_ms":"61"
#	},
#	"candlepin":{
#		"result":"fail",
#		"message":"Connection refused - connect(2)"
#	}
#}}



#-------------------------------------------------------------------------------
def main(argv):
	
	p = os.popen('curl -k http://localhost:3000/api/ping/ 2> /dev/null')
	response = p.readline()
	p.close()
	
	try:
		jResponse = simplejson.loads(response)
		
		#check pulp status
		if jResponse['status']['pulp']['result'] <> 'ok':
			msgFail('Pulp ping '+jResponse['status']['candlepin']['message'])
			
		if jResponse['status']['pulp_auth']['result'] <> 'ok':
			msgFail('Pulp auth '+jResponse['status']['candlepin']['message'])
		
		#check candlepin status
		if jResponse['status']['candlepin']['result'] <> 'ok':
			msgFail('Candlepin ping '+jResponse['status']['candlepin']['message'])
			
		if jResponse['status']['candlepin_auth']['result'] <> 'ok':
			msgFail('Candlepin auth '+jResponse['status']['candlepin_auth']['message'])
		
		#check overall status
		if jResponse['result'] == 'ok':
			msgOK('katello ping service')
			return 0
		else:
			msgFail('katello ping service')
			return 1
		
	except:
		#response is not valid json
		msgFail('katello ping service is not responding')
		return 1



#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
