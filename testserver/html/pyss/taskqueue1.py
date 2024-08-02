#!/usr/bin/python
import sys, os, datetime, time
import cgi, cgitb, sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

taskid = sys.argv[1]
a ='''<!DOCTYPE html>
<html><head>
<script> function change(){
top.location = "index.php";
}</script>
<link rel="stylesheet" type="text/css" href="css\style.css">
<script src="js/prefixfree.min.js"> </script>
</head><body>
<script src="js/index.js"> </script>
<?php
if($_POST['reset'] and $_SERVER['REQUEST_METHOD'] == "POST"){
reset_task();
//header("Location:taskqueue.php");
}
function reset_task(){
$command = escapeshellcmd("python pyss/reset.py '%s'");
$output = shell_exec($command);
}?>
<body><form method="post" action="">
<table bgcolor="#C4C4C4" align="" width="750" border="0">
<tr><td  align="center"colspan="2"><font color="#0000ff" size="6">Task in Queue</font></td></tr>
<tr><td width="312"></td><td width="172"> </td></tr>'''%taskid

print a

c.execute ("SELECT task, image, model, user, email, wan, ttype, stype, meta, ltask, status, submit_time, dispatch_time, priority, setup_id FROM queue WHERE task=?",[taskid])
for row in c.fetchall():
    if row[11] =='' or row[11] ==None:
       stime = ''
    else:
       stime = row[11]
       #stime = datetime.datetime.strptime(row[11], '%Y-%m-%d %H:%M:%S')
    if row[12] =='' or row[12] ==None:
       dtime = ''
    else:
       dtime = row[12]
       #dtime = datetime.datetime.strptime(row[12], '%Y-%m-%d %H:%M:%S')
       #dtime = datetime.datetime.strptime(row[12], '%Y%m%d%H%M%S')
    print '<tr><td><b>Task Id</b></td><td><input type="text" name="task" value="'
    print row[0]
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Image Path</b></td><td><input type="text" name="image" value="'
    print row[1]
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Model Name</b></td><td><input type="text" name="model" value="'
    print row[2]
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>User Name</b></td><td><input type="text" name="user" value="'
    print row[3]
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Email</b></td><td><input type="text" name="email" value="'
    print row[4]
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>WAN Mode</b></td><td><input type="text" name="wan" value="'
    print row[5]
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Test Type</b></td><td><input type="text" name="ttype" value="'
    print row[6]
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Test Sub Type</b></td><td><input type="text" name="stype" value="'
    print row[7]
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Meta Info</b></td><td><input type="text" name="meta" value="'
    print row[8]
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Parent Task Id</b></td><td><input type="text" name="ltask" value="'
    print row[9]
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Status</b></td><td><input type="text" name="status" value="'
    print row[10]
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Submit Time</b></td><td><input type="text" name="submit_time" value="'
    print stime
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Dispatch Time</b></td><td><input type="text" name="dispatch_time" value="'
    print dtime
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Priority</b></td><td><input type="text" name="priority" value="'
    if row[13] !=None:
       print row[13]
    else:
       print ''
    print '"readonly size="63"/></td></tr>'
    print '<tr><td><b>Test Setup Id</b></td><td><input type="text" name="setup_id" value="'
    if row[14] !=None:
       print row[14]
    else:
       print ''
    print '"readonly size="63"/></td></tr>'
    if row[10] != 'testing':
       print '<td align="center" colspan="2"><input type="submit" value="Reset Status" name="reset" onClick="reset_task()"/><input type="submit" value="Back" name="stop" onClick="change()"/></td>'
    else:
       print '<td align="center" colspan="2"><input type="submit" value="Back" name="stop" onClick="change();"/></td>'

#print '<td align="center" colspan="2"><input type="submit" value="Delete" name="delete" /><input type="submit" value="Stop" name="stop" /></td>'
#print '<td align="center" colspan="2"><input type="button" value="Back" name="stop" onClick="document.location.href=\'taskqueue.php\';"/></td>'
#print '<td align="center" colspan="2"><input type="submit" value="Reset Status" name="reset" /><input type="submit" value="Back" name="stop" onClick="history.go(-1);"/></td>'
print '</table></form></body></html>'

l.release()
c.close()
conn.close()
