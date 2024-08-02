#!/usr/bin/python
import sys, json, sqlite3, cgi, cgitb
import time, datetime, random
import os
from multiprocessing import Lock
from config import DB_PATH

"""sys.stdout = open("zzz1.txt", "w")
print os.environ

print sys.argv[0]
print sys.argv[1]
print sys.argv[2]
print sys.argv[3]
print sys.argv[4]
print sys.argv[5]
print sys.argv[6]
print sys.argv[7]
print sys.argv[8]
print sys.argv[9]
print sys.argv[10]
"""

l = Lock()
name =  sys.argv[1]
ipaddress =  sys.argv[2]
url_status =  sys.argv[3]
url_dispatch =  sys.argv[4]
url_stop =  sys.argv[5]
url_free =  sys.argv[6]
url_create_dir =  sys.argv[7]
url_log =  sys.argv[8]
url_tc =  sys.argv[9]
setup_id =  sys.argv[10]

#conn = sqlite3.connect('/var/www/html/testserver/db/bsptestserver.db')
conn = sqlite3.connect(DB_PATH)
print (conn)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

#c.execute("UPDATE setup set name=nam, ipaddress=ipaddres, url_status=url_statu, url_dispatch=url_dispatc, url_stop=url_sto, url_free=url_fre, url_create_dir=url_create_di WHERE setup_id=setup_i;")
#c.execute("INSERT INTO setup(name, ipaddress, url_status, url_dispatch, url_stop, url_free, url_create_dir) VALUES(?, ?, ?, ?, ?, ?, ?) WHERE setup_id=?", (name, ipaddress, url_status, url_dispatch, url_stop, url_free, url_create_dir, setup_id))

sql = """
UPDATE setup 
SET name = ?, ipaddress = ?, url_status = ?, url_dispatch = ?, url_stop = ?, url_free = ?, url_create_dir = ?, url_log = ?, url_tc = ? 
WHERE setup_id = ?
"""

c.execute(sql, (name, ipaddress, url_status, url_dispatch, url_stop, url_free, url_create_dir, url_log, url_tc, setup_id))

print "Updated database.";
conn.commit()

l.release()
c.close()
conn.close()
