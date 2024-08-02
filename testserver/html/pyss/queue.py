#!/usr/bin/python
import cgi, cgitb, sqlite3
import sys, os, datetime, time
from multiprocessing import Lock
from config import DB_PATH

cgitb.enable()

#op = "<td><input type=button value=Del onclick=\"DelId(this)\"> <input type=button value=Stop onclick=\"location.href='stop.php';\"> <input type=button value=Info onclick=\"Info(this)\"></td>"
op = "<td><input type=button value=Del onclick=\"DelId(this)\"> <input type=button value=Stop onclick=\"stop(this)\"> <input type=button value=Info onclick=\"Info(this)\"></td>"

print ""
l = Lock()

conn = sqlite3.connect(DB_PATH)
#conn = sqlite3.connect('pyss/basic_db.db')
c = conn.cursor()
l.acquire()

'''c.execute ("SELECT task, submit_time FROM queue")
rows = c.fetchall()
for row in rows:
    task1 = row[0]
    t1 = datetime.datetime.strptime(row[1], '%Y-%m-%d %H:%M:%S')
    #print t1
    c.execute ("UPDATE queue SET submit_time = ? WHERE task = ?", (t1,task1))'''

if len(sys.argv) <= 1:
    c.execute ("SELECT task, submit_time, user, model, wan, ttype, status, meta, tc_grp FROM queue")
else:
    taskid = sys.argv[1]
    c.execute ("SELECT * FROM queue WHERE task=?",[taskid])

print '<div style="width:100%;height:100%;position:absolute;vertical-align:middle;align:center;">'
print '<table id="tasklist" border=1>'
rows_count = c.fetchall()
if not rows_count:
   print '<tr><strong style="font-size:35px;color:green">No Tasks in Task Queue!</strong></tr>'
else:
   print '<tr><th>TaskId</th> <th>Submit<p>Time</th> <th>User</th> <th>Model</th> <th>WAN<p>Mode</th> <th>Test<p>Type</th> <th>Status</th> <th>Meta<p>Info</th> <th>Test Group</th> <th>Operation</th></tr>'
for row in rows_count:
    print '<tr>{}</tr>'.format(' '.join(['<td>{}</td>'.format(col) for col in row ])+op)

print '</table>'
#print '<input type="button" onclick="location.href=\'insert.php\';" value="New Task" style="margin-left:35%;margin-right:auto;display:block;margin-top:1%;margin-bottom:0%;height:30px;width:90px"/>'
print '</div>'

l.release()
c.close()
conn.close()
