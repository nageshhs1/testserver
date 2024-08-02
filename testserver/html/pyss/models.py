#!/usr/bin/python
import cgi, cgitb, sqlite3
import sys, os
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

op = "<td><input type=button value=Del onclick=\"DelId(this)\"> <input type=button value=Modify onclick=\"Modify(this)\"></td>"

#print "Content-type: text/html"
print ""
l = Lock()

#conn = sqlite3.connect('/var/www/html/testserver/db/bsptestserver.db')
conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

if len(sys.argv) <= 1:
    c.execute ("SELECT setup_id, board_id, model, eth, atm, ptm FROM models")
else:
    taskid = sys.argv[1]
    c.execute ("SELECT setup_id, board_id, model, eth, atm, ptm FROM models WHERE setup_id=?",[taskid])

#print '<table id="tasklist">'
print '<table id="model" border=1>'
print '<tr><th>Setup<p>Id</th> <th>Board<p>Id</th> <th>Model<p>Name</th> <th>ETH</th> <th>ATM</th> <th>PTM</th> <th>Operation</th></tr>'
for row in c:
    print '<tr>{}</tr>'.format(' '.join(['<td>{}</td>'.format(col) for col in row ])+op)
    print ""

print '</table>'
print '<input type="button" onclick="location.href=\'addmodel.php\';" value="Add Model" style="margin-left:5%;margin-right:auto;display:block;margin-top:1%;margin-bottom:0%;height:30px;width:90px"/>'

l.release()
c.close()
conn.close()
