#!/usr/bin/env python
# -*- coding: utf-8 -*-


import sys
import os
import simplejson
from utils import *


CPC_DIR = '/root/candlepin/client/ruby/'

#-------------------------------------------------------------------------------
def main(argv):

	#test if ./cpc list_products returns valid json response

	try:
		#os.chdir(CPC_DIR)
		p = os.popen(CPC_DIR+'./cpc list_products 2>/dev/null')
		response = p.readline()
		p.close()
	except:
		msgFail('could not run '+CPC_DIR+'cpc list_products', 'see https://fedorahosted.org/candlepin/wiki/Deployment')
		return 1
	
	try:
		simplejson.loads(response)
		msgOK('./cpc list_products')
		return 0
	except:
		msgFail('./cpc list_products', 'see https://fedorahosted.org/candlepin/wiki/Deployment')
		return 1


#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
