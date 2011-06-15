#!/usr/bin/env python
# -*- coding: utf-8 -*-


import sys
import os
from subprocess import Popen, PIPE, STDOUT
from utils import *


#-------------------------------------------------------------------------------
def main(argv):
	#test if pulp-admin works
	
	#call repo list, read stderr
	p = os.popen('pulp-admin repo list 2>&1 >/dev/null')
	response = p.readline()
	code = p.close()
	
	error = ((code <> None) and (code>>8))
	
	#fail if there was any output to stderr
	if not error:
		msgOK('pulp-admin')
		return 0
	else:
		msgFail('pulp-admin')
		return 1



#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
