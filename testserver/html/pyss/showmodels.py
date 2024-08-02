#!/usr/bin/python
import sys, os
import json, cgi, cgitb
import sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

op = "<td><input type=button value=Add onclick=\"Add(this)\"> <input type=button value=Del onclick=\"DelId(this)\"> <input type=button value=Modify onclick=\"Modify(this)\"></td>"

sys.stdout = open("log1.txt", "w")
print sys.argv[0]
print sys.argv[1]

taskid = sys.argv[1]
#print taskid
l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()
#print conn

#c.execute ("SELECT * FROM models WHERE setup_id=?",[taskid])
#conn.commit()

c.execute ("SELECT setup_id, board_id, model, eth, atm, ptm FROM models WHERE setup_id=?",[taskid])

print c.fetchall()
#c.execute ("SELECT task, user, model, wan, ttype, status, operation, meta FROM queue")

#print '<table id="models" border=1>'

for row in c:
    print '<tr>{}</tr>'.format(' '.join(['<td>{}</td>'.format(col) for col in row ])+op)
    print ""
#print '</table>'

l.release()
c.close()
conn.close()
