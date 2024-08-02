#!/usr/bin/python
import sys, json, sqlite3, cgi, cgitb
import time, datetime, random
import os
from multiprocessing import Lock
from config import DB_PATH

l = Lock()

task = 1
image =  sys.argv[1]
model =  sys.argv[2]
user =  sys.argv[3]
email =  sys.argv[4]
wan =  sys.argv[5]
ttype =  sys.argv[6]
stype =  sys.argv[7]
meta =  sys.argv[8]
operation = "<input type=button value=Result onclick=\"ResultId(this)\"><input type=button value=Del onclick=\"DelId(this)\"> <input type=button value=Retest onclick=\"ReTestId(this)\"> <input type=button value=TestFailOnly onclick=\"TestFailOnlyId(this)\">"
status = sys.argv[9]
stime = sys.argv[10]
dtime = sys.argv[11]
duration = sys.argv[12]
priority = sys.argv[13]

#conn = sqlite3.connect('/var/www/html/testserver/db/bsptestserver.db')
conn = sqlite3.connect(DB_PATH)

print (conn)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

c.execute('CREATE TABLE IF NOT EXISTS queue(task INTEGER PRIMARY KEY AUTOINCREMENT, image BLOB, model TEXT, user TEXT, email TEXT, wan TEXT, ttype TEXT, stype TEXT, status TEXT, meta BLOB, operation BLOB, stime TEXT, dtime TEXT, duration TEXT, priority INT)')
c.execute("INSERT INTO queue(image, model, user, email, wan, ttype, stype, status, meta, operation, stime, dtime, duration, priority) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", (image, model, user, email, wan, ttype, stype, status, meta, operation, stime, dtime, duration, priority))
conn.commit()
print "Task added to the Queue successfully.";

l.release()
c.close()
conn.close()

print """\
Content-Type: text/html\n
<html><body>
<p>Task added to the Queue successfully.!!!</p>
</body></html>
"""
