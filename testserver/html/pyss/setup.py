#!/usr/bin/python
import cgi, cgitb, sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

op = "<td><input type=button value=Res/Free onclick=\"Reserve(this)\" id=\"button\"> <input type=button value=Del onclick=\"DelId(this)\"> <input type=button value=Modify onclick=\"Modify(this)\"> <input type=button value=modelInfo onclick=\"modelInfo(this)\"></td>"

#print "Content-type: text/html"
print ""
l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

c.execute ("SELECT name, setup_id, ipaddress, url_status, url_dispatch, url_stop, url_free, url_create_dir, url_log, url_tc, state, reserved, task FROM setup")

#print '<table id="tasklist">'

print '<div style="width:100%;height:100%;position:absolute;vertical-align:middle;align:center;">'
print '<table id="setuplist" border=1>'
print '<tr><th>Name</th> <th>Setup<p>Id</th> <th>IP<p>Address</th> <th>URL<p>Status</th> <th>URL<p>Dispatch</th> <th>URL<p>Stop</th> <th>URL<p>Free</th> <th>URL<p>Create_Dir</th> <th>URL<p>Live ConsoleLog</th> <th>URL<p>Live TestCase</th> <th>State</th> <th>Reserved</th> <th>Running<p>TaskId</th> <th>Operation</th></tr>'
for row in c:
#    print '<tr>{}</tr>'.format(' '.join(['<td><input type =\'text\' value =\'{}\'></td>'.format(col) for col in row ])+op)
    print '<tr>{}</tr>'.format(' '.join(['<td>{}</td>'.format(col) for col in row ])+op)
    print ""

print '</table>'
print '<input type="button" onclick="location.href=\'addsetup.php\';" value="Add" style="margin-left:35%;margin-right:auto;display:block;margin-top:1%;margin-bottom:0%;height:30px;width:90px"/>'
print '</div>'

l.release()
c.close()
conn.close()
