#!/usr/bin/python
import sys, os
import json, cgi, cgitb
import sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

"""
sys.stdout = open("log1.txt", "w")
print sys.argv[0]
print sys.argv[1]

#print "Content-type: text/html"
#print ""
#print sys.argv[0]
"""
taskid = sys.argv[1]
#print taskid
l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()
print conn

c.execute ("DELETE FROM setup WHERE setup_id=?",[taskid])
c.execute ("DELETE FROM models WHERE setup_id=?",[taskid])
conn.commit()

#c.execute ("SELECT task, user, model, wan, ttype, status, operation, meta FROM queue")

#print '<table id="tasklist">'

#for row in c:
#    print '<tr>{}</tr>'.format(' '.join(['<td>{}</td>'.format(col) for col in row ]))
#    print ""
#print '</table>'

l.release()
c.close()
conn.close()
