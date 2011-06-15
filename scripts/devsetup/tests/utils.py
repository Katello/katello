#!/usr/bin/env python
# -*- coding: utf-8 -*-


import sys
import os
import re
import time

#-------------------------------------------------------------------------------
# Prints OK message
def msgOK(msg):
	print '[OK]     '+ msg
	return
	
#-------------------------------------------------------------------------------
# Prints failed message
def msgFail(msg, fix=None):
	print '[FAILED] '+ msg
	
	if fix != None:
		lines = fix.split("\n")
		print ' FIX:    '+lines[0]
		for l in lines[1:]:
			print '         '+l
	return

#-------------------------------------------------------------------------------
# Prints warning message
def msgWarn(msg):
	print '[WARN]   '+ msg
	return

#-------------------------------------------------------------------------------
# Checks if the package is installed and prints message. Returns True/False
def checkPackage(package):
	
	p = os.popen('rpm -q '+package)
	response = p.readline()
	p.close()

	if response.rfind('is not installed') >= 0:
		msgFail('missing package '+ package, 'yum install '+ package)
		return False
	else:
		msgOK('package '+ package +' installed')
		return True
		
#-------------------------------------------------------------------------------
# Checks if the package group is installed and prints message
def checkPackageGroup(group):
	
	status = False
	
	#run yum grouplist and check if name of the group is in the list 
	#prior to 'Available Groups' line
	p = os.popen('yum grouplist')
	for line in p.xreadlines():
		
		if line.find(group) >= 0:
			msgOK('package group '+ group +' installed')
			status = True
			break
		
		if line.find('Available Groups') >= 0:
			msgFail('missing package group '+ group)
			status = False
			break
		
	p.close()
	return status

#-------------------------------------------------------------------------------
# Returns version of installed package or None if the package is not installed.
def getPackageVersion(package):
	
	p = os.popen('yum info installed '+package+' 2> /dev/null')
	
	version = None
	for line in p.xreadlines():
		
		if line.find('Version') == 0:
			version = line.split(':')[1].strip()

	p.close()
	return version

#-------------------------------------------------------------------------------
# Tests if version of a package is higher or equal tehn required and prints 
# a message.
def checkPackageVersion(package, requiredVersion):
	
	version = getPackageVersion(package)
	if version == None:
		msgFail(package +' not installed')
		return False
	
	if version >= requiredVersion:
		msgOK(package +' '+ version)
		return True
	else:
		msgFail(package +' version '+ version +' ( required '+ requiredVersion +' )')
		return False

#-------------------------------------------------------------------------------
# Lists files id a directory. Files can by filtered with regexp
def listFiles(dir, regexp=None):

	try:
		root, dirs, files = os.walk(dir).next()
	except:
		return []
	
	if (regexp == None):
		#no filtering required, return all files
		return [root+'/'+f for f in files]

	return [root+'/'+f for f in files if re.match(regexp, f)]


#-------------------------------------------------------------------------------
# Looks for a last timestamp that matches format (strptime).
# If found, returns the timestamp in unix time. Otherwise
# returns None
def findLastTimestamp(filename, start, stop, format):

	#get last line of file
	try:
		f = open(filename)
		lines = f.readlines()
		f.close()
	except:
		msgOK(filename +' does not exist')
		return

	i = len(lines)-1

	while i>=0:
		strTime = lines[i][start:stop]
		#print strTime
		try:
			unixTime = time.mktime(time.strptime(strTime, format))
			return unixTime
		except:
			i = i-1

	return None
	
#-------------------------------------------------------------------------------
# Checks if there's a timestamp younger than rimeRange seconds
def checkLogFileTime(filename, start, stop, format, timeRange):

	unixTime = findLastTimestamp(filename, start, stop, format)
	if unixTime == None:
		msgOK('no timestamp recognized '+filename)
		return True

	#check time of last log message
	if (time.time()-unixTime) <= timeRange:
		msgWarn('there\'s recent message in file '+filename)
		return False
	else:
		msgOK('logfile '+filename)
		return True
	
#-------------------------------------------------------------------------------
# Checks if there's any error message in the file
def checkLogFile(filename):

	#call repo list, read stderr
	p = os.popen('cat '+ filename +' 2>/dev/null | egrep -i "error|fails" | wc -l')
	response = p.readline()
	p.close()
	
	#check time of last log message
	if int(response) > 0:
		msgWarn('there\'s error message in file '+filename)
		return False
	else:
		msgOK('logfile '+filename)
		return True
	
#-------------------------------------------------------------------------------
class Config:
	
	#---------------------------------------------------------------------------
	def __init__(self, filename):
		self.__config = {}
		self.__load(filename)
	
	#---------------------------------------------------------------------------
	def __load(self, filename):
		
		f = open(filename)
		for line in f.readlines():
			
			#skip blank lines
			line = line.strip()
			if line != "":
				colonPos = line.find(':')
				
				#store key: value
				key = line[0:colonPos].strip()
				value = line[colonPos+1:].strip()
				
				self.__config[key] = value
		
		f.close()
		
		return
	
	#---------------------------------------------------------------------------
	def getValue(self, key, defaultValue=None):
		if self.__config.has_key(key):
			return self.__config[key]
		else:
			return defaultValue
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
