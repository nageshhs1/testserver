#!/usr/bin/python
import sys, json, sqlite3, cgi, cgitb
import time, datetime, random
import os
from multiprocessing import Lock
from config import DB_PATH

l = Lock()
setup_id =  sys.argv[1]
board_id =  sys.argv[2]
model =  sys.argv[3]
eth =  sys.argv[4]
atm =  sys.argv[5]
ptm =  sys.argv[6]

conn = sqlite3.connect(DB_PATH)
print (conn)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

#c.execute('CREATE TABLE IF NOT EXISTS models(setup_id TEXT, board_id INTEGER, model BLOB, eth BLOB, atm BLOB, ptm BLOB)')
c.execute("INSERT INTO models(setup_id, board_id, model, eth, atm, ptm) VALUES(?, ?, ?, ?, ?,?)", (setup_id, board_id, model, eth, atm, ptm))
conn.commit()
print "Added to models table.";

l.release()
c.close()
conn.close()
