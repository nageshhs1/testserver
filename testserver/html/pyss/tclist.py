#!/usr/bin/python
import cgi, cgitb, sqlite3
import sys, os, datetime, time
from multiprocessing import Lock
from config import DB_PATH

cgitb.enable()

#sl = "<td><input type=\"checkbox\" style=\"zoom:1.5\">"

l = Lock()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

c.execute ("SELECT * FROM test_list")
rows_count = c.fetchall()
print '<form action="tc_page.php" method="post">'
print '<div style="width:100%;height:100%;position:absolute;vertical-align:middle;align:center;">'
print '<table id="testlist" border=1>'
print '<tr style="font-family:verdana;font-size:16px"><th>Select All<input type=\"checkbox\"  style=\"zoom:1.5\" onchange=\"checkAll(this)\" name=\"chk[]\"></th><th>TestCase Name</th> <th>TestCase Group</th> <th>Description</th></tr>'
for row in rows_count:
    sl = "<td><input type=\"checkbox\" style=\"zoom:1.5\" name=\"check_list[]\" value=\"%s\">"%(row[0])
    print '<tr>{}</tr>'.format(sl+' '.join(['<td>{}</td>'.format(col) for col in row ]))

print '</table>'
#print '<input type="button" onclick="save()" value="Save" style="margin-left:5%;margin-right:auto;display:block;margin-top:1%;margin-bottom:0%;height:30px;width:90px"/><input type="button" onclick="addnew()" value="New Test" style="height:30px;width:90px"/>'
print '<label for="tc_grp"><b>Enter TestGroup File Name:</b></label><input type="text" name="tc_grp" placeholder="Like TG_BSP_ALL" required/>'
#print '<input type="button" onClick="Info(this)" value="Save to File" style="height:35px;width:110px"/>    <input type="button" onclick="location.href=\'add_newtc.php\';" value="Add New Test" style="height:35px;width:110px"/>'
print '<input type="submit" value="Save to File" style="height:35px;width:110px"/>    <input type="button" onclick="location.href=\'add_newtc.php\';" value="Add New Test" style="height:35px;width:110px"/>'
print '</div>'
print '</form>'
l.release()
c.close()
conn.close()
