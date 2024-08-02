#!/usr/bin/python
import sys, json, sqlite3, cgi, cgitb
import time, datetime, random
import os
from multiprocessing import Lock
from config import DB_PATH

l = Lock()
task_id = sys.argv[1]

'''sys.stdout = open("zzz1.txt", "w")
print os.environ

print sys.argv[0]
print sys.argv[1]'''

conn = sqlite3.connect(DB_PATH)
print (conn)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

c.execute ("UPDATE queue SET status = 'waiting' WHERE task = ?",[task_id])

print "Updated database.";
conn.commit()

l.release()
c.close()
conn.close()

