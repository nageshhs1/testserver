#!/usr/bin/python
import sys, json, sqlite3, cgi, cgitb
import time, datetime, random
import os
from multiprocessing import Lock
from config import DB_PATH

'''
sys.stdout = open("zzz1.txt", "w")

print sys.argv[0]
print sys.argv[1]
print sys.argv[2]
print sys.argv[3]
print sys.argv[4]
print sys.argv[5]
print sys.argv[6]
print sys.argv[7]
print sys.argv[8]
'''

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
ltask =  sys.argv[9]
status = "waiting"
submit_time =  sys.argv[10]
tc_grp =  sys.argv[11]
dispatch_time = ''
finish_time = ''
duration = ''
ttime = ''
priority = ''
setup_id = ''

conn = sqlite3.connect(DB_PATH)
#conn = sqlite3.connect('pyss/basic_db.db')
print (conn)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

#c.execute('CREATE TABLE IF NOT EXISTS queue(task INTEGER PRIMARY KEY AUTOINCREMENT, image BLOB, model TEXT, user TEXT, email TEXT, wan TEXT, ttype TEXT, stype TEXT, meta BLOB, ltask INT, status TEXT, submit_time TEXT, dispatch_time TEXT, finish_time TEXT, duration TEXT, ttime TEXT, priority INT, setup_id INT)')
c.execute("INSERT INTO queue(image, model, user, email, wan, ttype, stype, meta, ltask, status, submit_time, dispatch_time, finish_time, duration, ttime, priority, setup_id, tc_grp) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", (image, model, user, email, wan, ttype, stype, meta, ltask, status, submit_time, dispatch_time, finish_time, duration, ttime, priority, setup_id, tc_grp))
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
