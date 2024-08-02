#!/usr/bin/python
import sys, os
import cgi, cgitb, sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

print ""
l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

setupid = sys.argv[1]

print '<body><form method="post" action="modifysetup.php">'
print '<table bgcolor="#C4C4C4" align="" width="580" border="0">'
print '<tr><td  align="center"colspan="2"><font color="#0000ff" size="6">Modify Setup</font></td></tr>'
print '<tr><td width="312"></td><td width="172"> </td></tr>'

c.execute ("SELECT * FROM setup WHERE setup_id=?",[setupid])
for row in c.fetchall():
    print '<tr><td>Setup Name </td><td><input type="text" placeholder="Setup Name" name="name" value='
    print row[0] 
    print '/></td></tr>'
    print '<tr><td>Setup Id </td><td><input type="text" placeholder="Setup Id" name="setup_id" value='
    print row[1] 
    print 'style="background-color:transparent" readonly/></td></tr>'
    print '<tr><td>IP Address</td><td><input type="text" placeholder="IP Address" name="ipaddress" value='
    print row[2] 
    print '/></td></tr>'
    print '<tr><td>URL Status</td><td><input type="text" placeholder="http://x.x.x.x/cgi-bin/auto_status.cgi" name="url_status" value='
    print row[3] 
    print '/></td></tr>'
    print '<tr><td>URL Dispatch</td><td><input type="text" placeholder="http://x.x.x.x/cgi-bin/auto_dispatch.cgi" name="url_dispatch" value='
    print row[4] 
    print '/></td></tr>'
    print '<tr><td>URL Stop</td><td><input type="text" placeholder="http://x.x.x.x/cgi-bin/auto_stop.cgi" name="url_stop" value='
    print row[5] 
    print '/></td></tr>'
    print '<tr><td>URL Free</td><td><input type="text" placeholder="http://x.x.x.x/cgi-bin/auto_free.cgi" name="url_free" value='
    print row[6] 
    print '/></td></tr>'
    print '<tr><td>URL Create Dir</td><td><input type="text" placeholder="http://x.x.x.x/tftpboot/" name="url_create_dir" value='
    print row[7] 
    print '/></td></tr>'
    print '<tr><td>URL Logs</td><td><input type="text" placeholder="http://x.x.x.x/auto_Live_log.pl" name="url_log" value='
    print row[8] 
    print '/></td></tr>'
    print '<tr><td>URL Live Test Case</td><td><input type="text" placeholder="http://x.x.x.x/auto_Live_testcase.html" name="url_tc" value='
    print row[9] 
    print '/></td></tr>'

#print '<td align="center" colspan="2"><input type="submit" value="Modify" name="submit"/> <input type="submit" value="Back" onClick="history.go(-1);"/></td>'
print '<td align="center" colspan="2"><input type="submit" value="Modify" name="submit"/> <input type="button" value="Back" onClick="document.location.href=\'setup.php\';"/></td>'
print '</table></form></body></html>'

l.release()
c.close()
conn.close()
