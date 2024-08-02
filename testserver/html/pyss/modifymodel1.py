#!/usr/bin/python
import sys, os
import cgi, cgitb, sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

setupid = sys.argv[1]
boardid = sys.argv[2]
model_name = sys.argv[3]

print '<body><form method="post" action="modifymodel.php">'
print '<table bgcolor="#C4C4C4" align="" width="580" border="0">'
print '<tr><td  align="center"colspan="2"><font color="#0000ff" size="6">Modify Model</font></td></tr>'
print '<tr><td width="312"></td><td width="172"> </td></tr>'

#c.execute("SELECT * FROM models WHERE board_id=?",[boardid])
c.execute ('SELECT * FROM models WHERE setup_id="%s" AND board_id="%s" AND model="%s"' % (setupid, boardid, model_name))
for row in c.fetchall():
    print '<tr><td>Setup Id </td><td><input type="text" placeholder="Setup Id" name="setup_id" value='
    print row[0] 
    print 'style="background-color:transparent" readonly/></td></tr>'
    print '<tr><td>Board Id </td><td><input type="text" placeholder="Board Id" name="board_id" value='
    print row[1] 
    print 'style="background-color:transparent" readonly/></td></tr>'
    print '<tr><td>Model Number </td><td><input type="text" placeholder="Model Number" name="model" value='
    print row[2] 
    print 'style="background-color:transparent" readonly/></td></tr>'
    print '<tr><td>WAN Mode ETH </td><td><input type="text" placeholder="0 or 1" name="eth" value='
    print row[3] 
    print '/></td></tr>'
    print '<tr><td>WAN Mode ATM </td><td><input type="text" placeholder="0 or 1" name="atm" value='
    print row[4] 
    print '/></td></tr>'
    print '<tr><td>WAN Mode PTM </td><td><input type="text" placeholder="0 or 1" name="ptm" value='
    print row[5] 
    print '/></td></tr>'

print '<td align="center" colspan="2"><input type="submit" value="Modify" name="submit"/> <input type="button" value="Back" onClick="document.location.href=\'setup.php\';"/></td>'
print '</table></form></body></html>'

l.release()
c.close()
conn.close()
