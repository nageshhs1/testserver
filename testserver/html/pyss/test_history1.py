#!/usr/bin/python
import sys, os,datetime, time
import cgi, cgitb, sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

taskid = sys.argv[1]

a = '''<!DOCTYPE html>
<html>
<head>
<script> function change(){
top.location = "test_history.php";
}</script>
<link rel="stylesheet" type="text/css" href="css\style.css">
<script src="js/prefixfree.min.js"> </script>
</head>
<body>
<nav class="animenu">
<ul class="animenu__nav">
<li>
<a href="">Results</a>
</li>
</ul>
</nav>'''

print a
#print '<form method="post" action="taskqueue1.php">'
print '<table bgcolor="#C4C4C4" align="" width="580" border="0">'
#print '<tr><td  align="center"colspan="2"><font color="#0000ff" size="6">Task Results</font></td></tr>'
print '<tr><td width="312"></td><td width="172"> </td></tr>'

c.execute ("SELECT * FROM test_history WHERE task=?",[taskid])
for row in c.fetchall():
    #stime = datetime.datetime.strptime(row[11], '%Y-%m-%d %H:%M:%S')
    #dtime = datetime.datetime.strptime(row[12], '%Y-%m-%d %H:%M:%S')
    #ftime = datetime.datetime.strptime(row[13], '%Y%m%d%H%M%S')
    print '<tr><td><b>Task Id</b></td><td><input type="text" name="task" value="'
    print row[0]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Image Path</b></td><td><input type="text" name="image" value="'
    print row[1]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Model Name</b></td><td><input type="text" name="model" value="'
    print row[2]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>User Name</b></td><td><input type="text" name="user" value="'
    print row[3]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Email</b></td><td><input type="text" name="email" value="'
    print row[4]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>WAN Mode</b></td><td><input type="text" name="wan" value="'
    print row[5]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Test Type</b></td><td><input type="text" name="ttype" value="'
    print row[6]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Test Sub Type</b></td><td><input type="text" name="stype" value="'
    print row[7]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Meta Info</b></td><td><input type="text" name="meta" value="'
    print row[8]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Parent Task Id</b></td><td><input type="text" name="ltask" value="'
    print row[9]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Status</b></td><td><input type="text" name="status" value="'
    #print row[10]
    print 'Completed'
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Submit Time</b></td><td><input type="text" name="submit_time" value="'
    #print stime
    print row[11]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Dispatch Time</b></td><td><input type="text" name="dispatch_time" value="'
    #print dtime
    print row[12]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Finished Time</b></td><td><input type="text" name="finish_time" value="'
    #print ftime
    print row[13]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Test Duration</b></td><td><input type="text" name="duration" value="'
    print row[14]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Total Duration</b></td><td><input type="text" name="ttime" value="'
    print row[15]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Priority</b></td><td><input type="text" name="priority" value="'
    print row[16]
    print '"readonly size="58"/></td></tr>'
    print '<tr><td><b>Test Setup Id</b></td><td><input type="text" name="setup_id" value="'
    print row[17]
    print '"readonly size="58"/></td></tr>'

#print '<td align="center" colspan="2"><input type="submit" value="Delete" name="delete" /><input type="submit" value="Stop" name="stop" /></td>'
#print '<td align="center" colspan="2"><input type="submit" value="Back" name="stop" onClick="history.go(-1);"/></td>'
print '<td align="center" colspan="2"><input type="button" value="Back" name="stop" onClick="change();"/></td>'
#print '<td align="center" colspan="2"><input type="submit" value="Back" name="stop" onClick="goto_history()"/></td>'
print '</table></form></body></html>'

l.release()
c.close()
conn.close()
