#!/usr/bin/env python
# -*- coding: utf-8 -*-


import sys
import os
from utils import *


#-------------------------------------------------------------------------------
def main(argv):
	
	#check the packages are installed
	
	success = True
	
	success = success and checkPackage('ruby')
	success = success and checkPackage('ruby-devel')
	success = success and checkPackage('rubygems')
	success = success and checkPackage('tomcat6')
	success = success and checkPackage('java-1.6.0-openjdk-devel')
	success = success and checkPackage('postgresql-server')
	success = success and checkPackage('mongodb')
	success = success and checkPackage('pulp')

	return 0 if success else 1

#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
