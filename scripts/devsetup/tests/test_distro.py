#!/usr/bin/env python
# -*- coding: utf-8 -*-


import sys
import os
from utils import *

#-------------------------------------------------------------------------------
# Returns distribution id and release number
def getDistroVersion():
	
	#get distro id
	p = os.popen('lsb_release -i')
	response = p.readline()
	p.close()

	distroId = response.split(":")[1].strip()

	#get distro release
	p = os.popen('lsb_release -r')
	response = p.readline()
	p.close()

	distroRelease = response.split(":")[1].strip()
	
	return distroId, distroRelease
	



#-------------------------------------------------------------------------------
def main(argv):
	
	#tests distribution compatibility
	#Fedora >= 13
	#RHEL >= 5
	
	distroId, distroRelease = getDistroVersion()
	if distroId == "Fedora":
		if int(distroRelease) >= 13:
			msgOK('Fedora '+ distroRelease)
			return 0
			
	elif distroId == "RHEL" :
		if int(distroRelease) >= 5:
			msgOK('RHEL '+ distroRelease)
			return 0

	msgFail('unsupported OS distribution')
	return 1
	


#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
