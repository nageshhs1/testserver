#!/usr/bin/python
import cgi, cgitb, sqlite3
import sys, os
from multiprocessing import Lock
from config import DB_PATH

cgitb.enable()

#op = "<td><input type=button value=Del onclick=\"DelId(this)\"><input type=button value=Info onclick=\"Info(this)\"></td>"

#print "Content-type: text/html"
print ""
l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

if len(sys.argv) <= 1:
    c.execute ("SELECT tc_name, result, duration FROM results")
else:
    taskid = sys.argv[1]
    c.execute ("SELECT * FROM results WHERE task=?",[taskid])

print '<table id="tasklist" border=1>'
print '<tr><th>TestCase_Name</th> <th>Result</th> <th>Duration</th></tr>'
for row in c:
#    print '<tr>{}</tr>'.format(' '.join(['<td>{}</td>'.format(col) for col in row ])+op)
    print '<tr>{}</tr>'.format(' '.join(['<td>{}</td>'.format(col) for col in row ]))
    print ""
print '</table>'

#meta = c.execute ("SELECT meta FROM queue")
#print(c.fetchone())

#for row in c:
#    print '<td>{}</td>'.format(''.format(col) for col in row )
#    print '</tr>'
l.release()
c.close()
conn.close()
