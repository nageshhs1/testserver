#!/usr/bin/python
import sys, json, sqlite3, cgi, cgitb
import time, datetime, random
import os
from multiprocessing import Lock
from config import DB_PATH

"""sys.stdout = open("zzz1.txt", "w")
print os.environ

print sys.argv[0]
print sys.argv[1]
print sys.argv[2]
print sys.argv[3]
print sys.argv[4]
print sys.argv[5]
print sys.argv[6]
print sys.argv[7]
print sys.argv[8]
"""

l = Lock()
name =  sys.argv[1]
#setup_id =  sys.argv[2]
ipaddress =  sys.argv[2]
url_status =  sys.argv[3]
url_dispatch =  sys.argv[4]
url_stop =  sys.argv[5]
url_free =  sys.argv[6]
url_create_dir =  sys.argv[7]
url_log =  sys.argv[8]
url_tc =  sys.argv[9]
state = 'Free'
reserved = 'No'
task = ''

#conn = sqlite3.connect('/var/www/html/testserver/db/bsptestserver.db')
conn = sqlite3.connect(DB_PATH)
#print (conn)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

c.execute('CREATE TABLE IF NOT EXISTS setup(name TEXT, setup_id INTEGER PRIMARY KEY AUTOINCREMENT, ipaddress BLOB, url_status BLOB, url_dispatch BLOB, url_stop BLOB, url_free BLOB, url_create_dir BLOB, url_log BLOB, url_tc BLOB, state TEXT, reserved TEXT, task INT)')
c.execute("INSERT INTO setup(name, ipaddress, url_status, url_dispatch, url_stop, url_free, url_create_dir, url_log, url_tc, state, reserved, task) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", (name, ipaddress, url_status, url_dispatch, url_stop, url_free, url_create_dir, url_log, url_tc, state, reserved, task))
conn.commit()
print "Added to database.";

l.release()
c.close()
conn.close()
