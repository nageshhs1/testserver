#!/usr/bin/python
import sys, json, sqlite3, cgi, cgitb
import time, datetime, random
import os, hashlib
from multiprocessing import Lock
from config import DB_PATH

"""
print os.environ
print sys.argv[0]
print sys.argv[1]
print sys.argv[2]
"""

l = Lock()

userid =  sys.argv[1]
passwd =  sys.argv[2]
hexhash = hashlib.sha512(passwd).hexdigest()

conn = sqlite3.connect(DB_PATH)
print (conn)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

c.execute('CREATE TABLE IF NOT EXISTS login(userid PRIMARY KEY, passwd BLOB)')
c.execute("INSERT INTO login(userid, passwd) VALUES(?, ?)", (userid, hexhash))
conn.commit()
print "Success.";

l.release()
c.close()
conn.close()

print """\
Content-Type: text/html\n
<html><body>
<p>User Added Successfully.!!!</p>
</body></html>
"""
