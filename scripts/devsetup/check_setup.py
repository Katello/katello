#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import subprocess
import getopt

TESTSCRIPTS_DIR = '/tests'

#-------------------------------------------------------------------------------
def listExecutables(path):
	
	#get all executable files recursively
	tmpFiles = []
	for root, dirs, files in os.walk(path):
		tmpFiles = tmpFiles + [root+'/'+f for f in files if os.access(root+'/'+f, os.X_OK)]
	
	return tmpFiles

#-------------------------------------------------------------------------------
def printHelp():
	print "Katello setup test scripts\n\
\n\
Usage:\n\
  ./check_setup.py [arguments]\n\
\n\
Arguments:\n\
  -h          prints this help\n\
  -f <flags>  format output\n\
              t - print filenames of test scripts that are being checked\n\
              o - print ok messages\n\
              w - print warnings\n\
              e - print errors\n\
              f - print fix hints,  takes effect only with f flag\n\
\n\
Example:\n\
  ./check_setup.py -f=we\n\
  Checks setup and prints only warning and error messages to standard output.\n\
"
	

#-------------------------------------------------------------------------------
def checkSetup(outputFilter):
	
	scriptCnt = 0
	failedCnt = 0
	
	printFile = (outputFilter.find('t') >= 0)
	printOk   = (outputFilter.find('o') >= 0)
	printWarn = (outputFilter.find('w') >= 0)
	printErr  = (outputFilter.find('e') >= 0)
	printFix  = (outputFilter.find('f') >= 0)
	
	#run all executable files in subdirectories
	for f in listExecutables(sys.path[0]+TESTSCRIPTS_DIR):
		
		p = subprocess.Popen(f, stdout=subprocess.PIPE)
		output = p.stdout.readlines()
		exitCode = p.wait()
		
		failedCnt = failedCnt + exitCode
		scriptCnt = scriptCnt + 1
		
		if (printFile):
			print
			print 'test '+ f
			
		for l in output:
			if printOk and l.startswith('[OK]'):
				print l[:-1]
			elif printWarn and l.startswith('[WARN]'):
				print l[:-1]
			elif printErr and l.startswith('[FAILED]'):
				print l[:-1]
			elif printErr and printFix and not l.startswith('['):
				print l[:-1]


	print '-'*50
	if failedCnt == 0:
		print 'All tests passed'
		return 0
	else:
		print str(failedCnt) +' of '+ str(scriptCnt) +' tests failed'
		return 1


#-------------------------------------------------------------------------------
def main(argv):
	
	helpAndExit = False
	outputFilter = "towe"
	
	try:
		opts, args = getopt.getopt(argv, "hf:")
	except:
		print >> sys.stderr, 'Unknown parameter!'
		return
	
	for option, value in opts:
		if (option == "-f"):
			outputFilter = value
		elif (option == "-h"):
			helpAndExit = True
			
	
	if helpAndExit:
		printHelp()
		return 0
	
	return checkSetup(outputFilter)

#-------------------------------------------------------------------------------
if __name__ == "__main__":
	exit(main(sys.argv[1:]))
