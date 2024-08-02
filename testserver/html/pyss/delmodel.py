#!/usr/bin/python
import sys, os
import json, cgi, cgitb
import sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

'''sys.stdout = open("zzz1.txt", "w")
print sys.argv[0]
print sys.argv[1]
print sys.argv[2]'''

setupid = sys.argv[1]
boardid = sys.argv[2]
model = sys.argv[3]

l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

#c.execute ("DELETE FROM models WHERE board_id=?",[boardid])
c.execute ('DELETE FROM models WHERE setup_id="%s" AND board_id="%s" AND model="%s"' % (setupid, boardid, model))
conn.commit()

l.release()
c.close()
conn.close()
