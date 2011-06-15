#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
from utils import *

#/etc/pulp/pulp.conf, /etc/candlepin/candlepin.conf, /etc/katello/katello.yml


#-------------------------------------------------------------------------------
def getSatteliteTokens():

#candlepin:
#  development:
#    oauth_key: katello
#    oauth_secret: FFkQr9W8PjVFMCguL3XYzv2O

#pulp:
#  development:
#    url: https://localhost/pulp/api
#    oauth_key: katello
#    oauth_secret: FFkQr9W8PjVFMCguL3XYzv2O

	SECT_PULP, SECT_CP, SECT_OTHER = range(3)

	pulpAuth = None
	pulpSecret = None
	cpAuth = None
	cpSecret = None

	section = SECT_OTHER

	try:
		#read yaml file, check what section we're in and look for tokens
		f = open('/etc/katello/katello.yml')
		for line in f.xreadlines():
			
			if line.startswith('candlepin'):
				section = SECT_CP
				
			elif line.startswith('pulp'):
				section = SECT_PULP
				
			elif not line.startswith(' '):
				section = SECT_OTHER
						
			else:
				line = line.strip()
				#look for oauth_key
				if line.startswith('oauth_key:'):
					if section == SECT_CP:
						cpAuth = line.split(':')[1].strip()
					elif section == SECT_PULP:
						pulpAuth = line.split(':')[1].strip()
				
				#look for oauth_secret
				if line.startswith('oauth_secret:'):
					if section == SECT_CP:
						cpSecret = line.split(':')[1].strip()
					elif section == SECT_PULP:
						pulpSecret = line.split(':')[1].strip()
				
		f.close()
	except:
		msgFail('could not read /etc/katello/katello.yml')

	return pulpAuth, pulpSecret, cpAuth, cpSecret

#-------------------------------------------------------------------------------
def getPulpTokens():
	#oauth_key: katello
	#oauth_secret: FFkQr9W8PjVFMCguL3XYzv2O

	auth = None
	secret = None

	try:
		f = open('/etc/pulp/pulp.conf')
		for line in f.xreadlines():
			if line.startswith('oauth_key:'):
				auth = line.split(':')[1].strip()
			if line.startswith('oauth_secret:'):
				secret = line.split(':')[1].strip()
		f.close()
		
	except:
		msgFail('could not read /etc/pulp/pulp.conf')
	
	return auth, secret

#-------------------------------------------------------------------------------
def getCandlepinTokens():
	#candlepin.auth.oauth.consumer.katello.secret = FFkQr9W8PjVFMCguL3XYzv2O
	
	auth = None
	secret = None

	try:
		f = open('/etc/candlepin/candlepin.conf')
		for line in f.xreadlines():
			if line.startswith('candlepin.auth.oauth.consumer.katello.secret'):
				secret = line.split('=')[1].strip()
				auth = 'katello'
		f.close()
	except:
		msgFail('could not read /etc/candlepin/candlepin.conf')
		
	return auth, secret


#-------------------------------------------------------------------------------
def main(argv):
	
	#test if auth and secret tokens in fonfig files match
	
	satPulpAuth, satPulpSecret, satCpAuth, satCpSecret = getSatteliteTokens()
	pulpAuth, pulpSecret 			= getPulpTokens()
	candlepinAuth, candlepinSecret 	= getCandlepinTokens()
	
	tokensMatch = (satPulpAuth == satCpAuth == pulpAuth == candlepinAuth != None)
	tokensMatch = tokensMatch and (satPulpSecret == satCpSecret == pulpSecret == candlepinSecret != None)
	
	if tokensMatch:
		msgOK('auth and secret tokens in config files match')
		return 0
	else:
		msgFail('auth and secret tokens in config files don\'t match', 
"check files\n\
/etc/katello/katello.yml\n\
/etc/pulp/pulp.conf\n\
/etc/candlepin/candlepin.conf\n\
and set correct tokens")
		return 1



#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
