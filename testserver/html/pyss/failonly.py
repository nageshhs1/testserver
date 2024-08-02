#!/usr/bin/python
import sys, os
import subprocess
import cgi, cgitb, sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

ltask = sys.argv[1]
submit_time = sys.argv[2]
testing_task_id = ltask
#--------------------------------------------------------------------------------------------------------------------------------------------#
def lcount(keyword, fname):
      with open(fname, 'r') as fin:
         return sum([1 for line in fin if keyword in line])

#--------------------------------------------------------------------------------------------------------------------------------------------#
conn = sqlite3.connect(DB_PATH)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
#l.acquire()

c.execute ("SELECT image, model, user, email, wan, ttype, stype, meta, tc_grp FROM test_history WHERE task=?",[ltask])
for row in c.fetchall():
    image = row[0]
    model = row[1]
    user = row[2]
    email = row[3]
    wan = row[4]
    ttype = row[5]
    stype = row[6]
    meta = '%s'%row[7]
    tc_grp = row[8]
    print meta
    #print wan
conn.commit()
c.close()
conn.close()

#----------------------------------------------------------------------------------------------------------------------------------------------#
wan = str(wan)
if ('all' in wan) or ('ALL' in wan):
     wan_list = ['eth','atm','ptm']
else:
    wan = wan.lower()
    wan_list = wan.split(",")

#print wan_list
new_wan_list =[]
#new_wan_list = ''
for each in wan_list:
    file1 = "/testserver/db/log/task/%s/result_%s.htm"%(testing_task_id,each)
    #print file1
    key1 = '<td>ok'
    key2 = '>Failed'
    key3 = '>fail<'
    if os.path.isfile(file1) and each in wan_list:
       statinfo = os.stat(file1)
       size = statinfo.st_size
       if os.path.isfile(file1) and size > 4:
          Pass = lcount(key1, file1)
          b = lcount(key2, file1)
          e = lcount(key3, file1)
          Fail = b+e
          print Fail,Pass
          if Fail != 0 or (Pass==Fail == 0):
             #print each
             new_wan_list += [each.upper()]
             #print new_wan_list
       else:
        new_wan_list += []
    else:
        new_wan_list += []
print new_wan_list
if new_wan_list != []:
   wan_list = new_wan_list
   print wan_list
   t=len(wan_list)
   wan = str(wan_list)
   #print wan
   new_list = ''
   for i in range (0,t):
       new_list = wan_list[i] + "," + new_list

   #print new_list
   var = new_list.strip(','); 
   print var
   subprocess.call("python /testserver/html/pyss/insert.py '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s'" %(image,model,user,email,var,ttype,stype,meta,ltask,submit_time,tc_grp), shell=True)
   print "Task added to the Queue successfully.";
else :
   wan_list = []
