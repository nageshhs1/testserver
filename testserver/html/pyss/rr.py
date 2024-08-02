#!/usr/bin/python
import sys, os
import subprocess

'''sys.stdout = open("zzz1.txt", "w")
print os.environ

print sys.argv[0]
print sys.argv[1]'''

taskid = sys.argv[1]

#print subprocess.call(["php","-f","/testserver/html/rr.php",taskid])
t = subprocess.call("php /testserver/html/rr.php '%s'"%taskid, shell=True)
#print t
