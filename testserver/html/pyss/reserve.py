#!/usr/bin/python
import sys, json, sqlite3, cgi, cgitb
import time, datetime, random
import os
from multiprocessing import Lock
from config import DB_PATH

l = Lock()
reserve = "No"
setup_id =  sys.argv[1]

conn = sqlite3.connect(DB_PATH)
print (conn)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

c.execute ("SELECT state, reserved FROM setup WHERE setup_id=?",[setup_id])
for row in c.fetchall():
    if row[1] == 'Yes':
        sql = """UPDATE setup SET reserved = ? WHERE setup_id = ?"""
        c.execute(sql, (reserve, setup_id))
    else:
        c.execute ("UPDATE setup SET reserved = 'Yes' WHERE setup_id = ?",[setup_id])

"""sql = 
UPDATE setup
SET reserved = ?
WHERE state = 'Free' AND setup_id = ?
c.execute(sql, (reserve, setup_id))"""

print "Updated database.";
conn.commit()

l.release()
c.close()
conn.close()
