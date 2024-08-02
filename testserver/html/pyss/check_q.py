#!/usr/bin/python
import cgi, cgitb, sqlite3
import sys, os, datetime, time
from multiprocessing import Lock
from config import DB_PATH

cgitb.enable()

l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

c.execute("SELECT * FROM queue")
#print(c.fetchall())
res=c.fetchall()

if len(res)==0:
   print 0
else:
   print 1

l.release()
c.close()
conn.close()
