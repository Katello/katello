#!/usr/bin/env python
# -*- coding: utf-8 -*-


import sys
import os
from utils import *



#-------------------------------------------------------------------------------
def main(argv):
	#test if package group 'Development Tools' is installed
	
	if checkPackageGroup('Development Tools'):
		return 0
	else:
		return 1



#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))