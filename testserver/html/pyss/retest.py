#!/usr/bin/python
import sys, os
import subprocess
import cgi, cgitb, sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

l = Lock()

ltask = sys.argv[1]
submit_time = sys.argv[2]
'''status = 'waiting'
dispatch_time = '0'
priority = 1
setup_id = '0'
'''

conn = sqlite3.connect(DB_PATH)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

'''c.execute("INSERT INTO queue(image, model, user, email, wan, ttype, stype, meta, ltask, setup_id, status, submit_time, dispatch_time, priority) SELECT image, model, user, email, wan, ttype, stype, meta, task, ?, ?, ?, ?, ? FROM test_history WHERE task=?",(setup_id, status, submit_time, dispatch_time, 0, ltask))
#c.execute("INSERT INTO queue(status, submit_time, dispatch_time, priority) VALUES(?, ?, ?, ?)", (status, submit_time, dispatch_time, priority))'''

c.execute ("SELECT image, model, user, email, wan, ttype, stype, meta, tc_grp FROM test_history WHERE task=?",[ltask])
for row in c.fetchall():
    image = row[0]
    model = row[1]
    user = row[2]
    email = row[3]
    wan = row[4]
    ttype = row[5]
    stype = row[6]
    meta = '%s'%row[7]
    tc_grp = row[8]
    print meta

conn.commit()
l.release()
c.close()
conn.close()

subprocess.call("python pyss/insert.py '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s'" %(image,model,user,email,wan,ttype,stype,meta,ltask,submit_time,tc_grp), shell=True)

print "Task added to the Queue successfully.";
