#!/usr/bin/python
import cgi, cgitb, sqlite3
import sys, os, hashlib
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

"""
sys.stdout = open("file1.txt", "w")
print sys.argv[0]
print sys.argv[1]
print sys.argv[2]
"""

l = Lock()
userid = sys.argv[1]
passwd = sys.argv[2]
revhash = hashlib.sha512(passwd).hexdigest()

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()
#print conn
print ""

c.execute ('SELECT * FROM login WHERE userid="%s" AND passwd="%s"' % (userid, revhash))
#c.execute ("SELECT * FROM login WHERE userid = 'userid' AND passwd = 'passwd'")

if (c.fetchone()):
    print "Welcome"
else:
    print "Login failed"

print ""
conn.commit()

l.release()
c.close()
conn.close()
