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
"""
l = Lock()
setup_id =  sys.argv[1]
model =  sys.argv[2]
eth =  sys.argv[3]
atm =  sys.argv[4]
ptm =  sys.argv[5]
board_id =  sys.argv[6]

conn = sqlite3.connect(DB_PATH)
print (conn)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

sql = """
UPDATE models
SET eth = ?, atm = ?, ptm = ?
WHERE model = ? AND board_id = ? AND setup_id = ?
"""
#WHERE setup_id = ? AND board_id = ? AND model = ? AND eth = ? AND atm = ? AND ptm = ?

c.execute(sql, (eth, atm, ptm, model, board_id, setup_id))

print "Updated database.";
conn.commit()

l.release()
c.close()
conn.close()
