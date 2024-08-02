#!/usr/bin/python
import sys, os
import cgi, cgitb, sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()


l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

taskid = sys.argv[1]

c.execute("SELECT ipaddress FROM setup WHERE task=?",[taskid])
row = c.fetchone()
print row[0]

'''
c.execute("SELECT status FROM queue WHERE task=?",[taskid])
row = c.fetchone()
#print row[0]
if row[0] == 'testing':
   c.execute("SELECT ipaddress FROM setup WHERE task=?",[taskid])
   row = c.fetchone()
   print row[0]
else:
   print 'Task is Not Launched'
'''
l.release()
c.close()
conn.close()
