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
"""

l = Lock()
tc_name =  sys.argv[1]
tc_grp =  sys.argv[2]
description =  sys.argv[3]

conn = sqlite3.connect(DB_PATH)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

c.execute('CREATE TABLE IF NOT EXISTS test_list(tc_name TEXT, tc_grp TEXT, description BLOB)')
c.execute("INSERT INTO test_list(tc_name, tc_grp, description) VALUES(?, ?, ?)", (tc_name, tc_grp, description))

conn.commit()
print "Added to database.";

l.release()
c.close()
conn.close()
