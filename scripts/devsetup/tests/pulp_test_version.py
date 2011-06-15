#!/usr/bin/env python
# -*- coding: utf-8 -*-


import sys
import os
from utils import *


#-------------------------------------------------------------------------------
def main(argv):
	#test if version of pulp is >= required
	
	#load required version from config
	cfg = Config(sys.path[0]+'/../config.cfg')
	requiredVersion = cfg.getValue('pulp_version')

	if checkPackageVersion('pulp', requiredVersion):
		return 0
	else:
		return 1



#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
