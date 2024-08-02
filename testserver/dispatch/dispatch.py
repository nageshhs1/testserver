#!/usr/bin/python
# Dispatch Module #
#Python modules used in the script
import os,random,io 
import time,commands,datetime 
import re,sqlite3,shutil
from multiprocessing import Lock
from shutil import copyfile

#Get the server IP and store it as global variable
ip = os.popen('ifconfig -a | grep "inet\ addr:10.226" | cut -d: -f2 | cut -d " " -f1')
your_ip=ip.read()
global testserver_ip
ip = your_ip.split("\n")
testserver_ip = ip[0]
#print testserver_ip 

#flags 
Start_deamon_flag = 1
task_queue_Testing = 1
task_queue_Waiting = 0
counter = 0 # To count number of while loops # It can be removed 

#Variables
 
global db_name
db_name = '/testserver/db/bsptestserver.db'
queue_table = 'queue'
setup_table = 'setup'
model_table = 'models'
history_table = 'test_history'
setup_info = "/testserver/db/setup_info/"
#Error counters
global get_status_error_count,make_free_error_count,submit_task_error_count,create_dir_error_count,get_result_error_count 
create_dir_error_count = get_status_error_count = make_free_error_count = submit_task_error_count = get_result_error_count = 0

# Need to define log structure#
import logging 
global logger
logger = logging.getLogger('')
FORMAT = '%(asctime)-15s {%(funcName)s} %(message)s'
logging.DEBUG = 1
logging.INFO = 1
console_print = 0
#t = datetime.datetime.now()
#t= t.replace(microsecond=0)
#log_date = str(t.strftime('%Y%m%d'))
#log_file = "/testserver/db/log/automation_log_%s.log"%(log_date)
#print log_file

# Create a log file automation.log to capture the activities
#logging.basicConfig(filename=log_file,level=logging.DEBUG,format=FORMAT)
logging.basicConfig(filename='/testserver/db/log/automation.log',level=logging.DEBUG,format=FORMAT)
logger.info('#\n\n\n TESTSERVER LOGS \n ===============\n\n\n')
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Get_free_setup_id_list():
    if console_print:
         print "Get the free setup id from the setup table data"
    global setup_id_list
    #Set the required parameters to read the database. 
    column_to_read = 'setup_id'
    column_id = 'state'
    column_value = 'Free'
    column_id2 = 'reserved'
    column_value2 = 'No'
    # Task id can be added in the condition to ensure the setup free state
    # Call a function to read the Test_setup database 
    Read = Read_database()
    setup_id_list = Read.read_query2(db_name,setup_table,column_to_read,column_id,column_value,column_id2,column_value2)
    if setup_id_list == []:
       if logger.isEnabledFor(logging.INFO):
                 logging.error('Free setup Id list is Empty')
    #if console_print: print "Free setup ids are: %s"%(setup_id_list)
    for setup_id in setup_id_list:
         #Get ip and url
         ip,url = Get_ip_url(setup_id,'url_status')
         #"call a function to polling device using ip and url"
         result = Get_polling_data(ip,url)
         #"Need to handle the device polling failures"
         if result == 1:
              if console_print:
                  print "Device polling failed and device not accessible"
              if logger.isEnabledFor(logging.DEBUG):
                 logging.error('Device polling failed and device not accessible')
              return 1,1
         setup_status = result
         #Get status
         print "Current status of the free setup : %s"%(setup_status)
         if setup_status == 'finished':
                url = "curl --request POST 'http://%s/cgi-bin/auto_free.cgi HTTP/1.1' --data 'submit=submit'"%(ip)
                os.system(url)
                print "Current status of the setup changed to free"
                if logger.isEnabledFor(logging.DEBUG):
                   logging.error('Device is not in free state update the setup table to Free')
    setup_id_list = Read.read_query2(db_name,setup_table,column_to_read,column_id,column_value,column_id2,column_value2)
    return setup_id_list
#------------------------------------------------------------------------------------------------#
def Get_model_name_list(setup_id):
    #Get the model list which are supported by each setup 
    logging.info(" The Setup ID is : %s"%(setup_id))
    column_to_read = 'model'
    column_id = 'setup_id'
    column_value = setup_id
    #can be added setup status to verify the device state
    Read = Read_database()
    model_name_list = Read.read_query(db_name,model_table,column_to_read,column_id,column_value)
    #if console_print:print "Models supported in setup_id %s are : %s"%(setup_id,model_name_list)
    if model_name_list == []:
       if logger.isEnabledFor(logging.INFO):
                   logging.error('Model list is empty')
    return model_name_list

#-----------------------------------------------------------------------------------------------#
def Get_reserve_flag_state(setup_id):
    column_to_read = 'reserved'
    column_id = 'setup_id'
    column_value = setup_id
    column_to_read2 = 'state'
    Read = Read_database()
    
    #print column_to_read,column_to_read2,column_id,column_value
    reserve_flag,current_status = Read.two_value_query(db_name,setup_table,column_to_read,column_to_read2,column_id,column_value)
    #print reserve_flag,current_status
    if reserve_flag == '' and current_status =='':
       if logger.isEnabledFor(logging.INFO):
                   logging.error('Improper flag state found')
    return reserve_flag,current_status
    


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Get_wan_list_per_model(model,setup_id):
    #Get the supported wan_mode list for the model
    column_to_read1 = 'eth'
    column_to_read2 = 'atm'
    column_to_read3 = 'ptm'
    column_id = 'setup_id'
    column_value = setup_id
    column_id2 = 'model'
    column_value2 = model
    Read = Read_database()	 
    result = Read.read_multiple_column(db_name,model_table,column_to_read1,column_to_read2,column_to_read3,column_id,column_value,column_id2,column_value2)
    if result == []:
       if logger.isEnabledFor(logging.INFO):
          logging.info('WAN Mode List is empty')
    if console_print:
           print result
    wan_list_per_model = []
    if result[0]== 1:
       wan_list_per_model.append('eth')
    if  result[1]== 1:
       wan_list_per_model.append('atm')
    if result[2] == 1:
       wan_list_per_model.append('ptm')
    if console_print:
       print " Wan modes supported in the model %s are %s"%(model,wan_list_per_model) 
    return wan_list_per_model
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# A general function to read/query the database 
class Read_database(object):
   def read_query(self,db_name,table_name,column_to_read,column_id,column_value):
     conn = sqlite3.connect(db_name)
     c = conn.cursor()
     c.execute("SELECT %s FROM %s WHERE %s = '%s'"%(column_to_read,table_name,column_id,column_value))
     conn.commit()
     row = c.fetchall()
     conn.close()
     if row == []:
        if console_print:
           print "No suitable element found in list, Please check the input parameters"
        return row
     else:
        
        num = list(sum(row, ()))
        return num

   def read_query2(self,db_name,table_name,column_to_read,column_id,column_value,column_id2,column_value2):
     conn = sqlite3.connect(db_name)
     c = conn.cursor()
     c.execute("SELECT %s FROM %s WHERE %s = '%s' and %s = '%s'"%(column_to_read,table_name,column_id,column_value,column_id2,column_value2))
     conn.commit()
     row = c.fetchall()
     conn.close()
     if row == []:
        if console_print:
           print "No suitable element found in list, Please check the input parameters"
        return row
     else:

        num = list(sum(row, ()))
        return num


    
   def two_value_query(self,db_name,table_name,column_to_read,column_to_read2,column_id,column_value):
     conn = sqlite3.connect(db_name)
     c = conn.cursor()
     c.execute("SELECT %s,%s FROM %s WHERE %s = '%s'"%(column_to_read,column_to_read2,table_name,column_id,column_value))
     conn.commit()
     row = c.fetchall()
     #print row
     conn.close()
     if row == []:
        if console_print:
           print "No suitable element found in list, Please check the input parameters"
        return row
     else:

        num = list(sum(row, ()))
        return num[0],num[1]





 
   def fetchone_query(self,db_name,table_name,column_to_read,column_id,column_value,column_id2,column_value2):
     conn = sqlite3.connect(db_name)
     c = conn.cursor()
     #if console_print:print column_to_read,table_name,column_id,column_value,column_id2,column_value2
     c.execute("SELECT %s FROM %s WHERE %s = '%s' and %s = '%s'"%(column_to_read,table_name,column_id,column_value,column_id2,column_value2))
     conn.commit()
     row = c.fetchone()
     conn.close()
     if row == [] or row == None:
        if console_print:
            print "No suitable element found in list, Please check the input parameters"
        return row
     else:

        #print row
        return row[0] 
   def fetchone_query2(self,db_name,table_name,column_to_read,column_id,column_value,column_id2,column_value2,column_id3,column_value3):
     conn = sqlite3.connect(db_name)
     c = conn.cursor()
     #if console_print:print column_to_read,table_name,column_id,column_value,column_id2,column_value2
     c.execute("SELECT %s FROM %s WHERE %s = '%s' and %s = '%s' and %s = '%s'"%(column_to_read,table_name,column_id,column_value,column_id2,column_value2,column_id3,column_value3))
     conn.commit()
     row = c.fetchone()
     conn.close()
     if row == [] or row == None:
        if console_print:
            print "No suitable element found in list, Please check the input parameters"
        return row
     else:

        #print row
        return row[0]



   def read_multiple_column(self,db_name,table_name,column_to_read1,column_to_read2,column_to_read3,column_id,column_value,column_id2,column_value2):
      conn = sqlite3.connect(db_name)
      c = conn.cursor()
      c.execute("SELECT %s,%s,%s FROM %s WHERE %s = '%s'and %s = '%s'"%(column_to_read1,column_to_read2,column_to_read3,table_name,column_id,column_value,column_id2,column_value2))
      conn.commit()
      row = c.fetchall()
      conn.close()
      if len(row)!= 1:
          num = tuple(i or j for i, j in zip(row[0], row[1]))
          num = list(num)
          return num
      if row == []:
        if console_print:
           print "No suitable element found in list, Please check the input parameters"
        return row
      else:
        num = list(sum(row, ()))
        return num
   def read_mutli(self,db_name,table_name,column_to_read1,column_to_read2,column_to_read3,column_id,column_value,column_id2,column_value2,column_id3,column_value3):
      conn = sqlite3.connect(db_name)
      c = conn.cursor()
      c.execute("SELECT %s,%s,%s FROM %s WHERE %s = '%s'and %s = '%s'and %s = '%s'"%(column_to_read1,column_to_read2,column_to_read3,table_name,column_id,column_value,column_id2,column_value2,column_id3,column_value3))
      conn.commit()
      row = c.fetchall()
      conn.close()
      if len(row)!= 1:
          num = tuple(i or j for i, j in zip(row[0], row[1]))
          num = list(num)
          return num
      if row == []:
        if console_print:
           print "No suitable element found in list, Please check the input parameters"
        return row
      else:
        num = list(sum(row, ()))
        return num
  
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Get_Waiting_Task_ids():
    if console_print:
       print "Get Waiting Task IDs" 
    column_to_read = 'task'
    column_id = 'status'
    column_value = 'waiting' 
    Read = Read_database()
    waiting_task_ids= Read.read_query(db_name,queue_table,column_to_read,column_id,column_value)
    #if console_print:print "Waiting task ids are:%s"%(waiting_task_ids)
    return waiting_task_ids 

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

def Get_wan_list(task_id):
    if task_id != '':
       column_to_read = 'wan'
       column_id = 'task'
       column_value = task_id 
       Read = Read_database()
       wan_list= Read.read_query(db_name,queue_table,column_to_read,column_id,column_value) 
       #if 'all' in wan_list or 'ALL' in wan_list:
       #    wan_list = ['eth','atm','ptm']
       #if console_print:print "Wan modes need to be tested for the task id : %s are %s"%(task_id, wan_list)
       x =wan_list[0]
       wan_list = x.split(",")
       wan_list = map(str,wan_list)
       wan_list = map(str.lower,wan_list)
       if 'all' in wan_list:
           wan_list = ['eth','atm','ptm']
       print "Wan modes need to be tested for the task id : %s are %s"%(task_id, wan_list)
       return wan_list
    else:
      if logger.isEnabledFor(logging.DEBUG):
         logging.error('Improper task id')
      return [None]

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Get_model_name_of_task(task_id):
    if task_id != '':
       column_to_read = 'model'
       column_id = 'task'
       column_value = task_id
       column_id2 = 'status'
       column_value2 = 'waiting'
       Read = Read_database()
       model_name_of_task= Read.fetchone_query(db_name,queue_table,column_to_read,column_id,column_value,column_id2,column_value2)
       #if console_print:print "Model name for the task id : %s is %s"%(task_id, model_name_of_task)
       return model_name_of_task
    else:
       if logger.isEnabledFor(logging.DEBUG):
          logging.error('Improper task id')
       return 1

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Update_Test_setup_table_to(state,setup_id,task_id):
    print "Testing Setup ID : %s"%(setup_id)
    print "Setup Status : %s "%(state)
    print "Running Task ID : %s"%(task_id)
    conn = sqlite3.connect(db_name)
    c = conn.cursor()
    l = Lock()
    l.acquire()
    try:
      c.execute("UPDATE %s SET state = ?,task = ? WHERE setup_id =?"%(setup_table), (state, task_id, setup_id))
    except sqlite3.OperationalError:
           logging.error('DB UPDATE Error')
           conn.commit()
           l.release()
           conn.close()
           return 1
    except : 
       if console_print:
          print "DB UPDATE Error,Check %s table and Task ID:%s"%(setup_table,task_id)
       if logger.isEnabledFor(logging.DEBUG):
           logging.error('DB UPDATE Error,Check %s table and Task ID:%s',setup_table,task_id)
       conn.commit()
       l.release()
       conn.close()
       return 1
    conn.commit()
    l.release()
    conn.close()
    if logger.isEnabledFor(logging.DEBUG):
       logging.info("setup {bid} status updated to {st}".\
           format(bid = setup_id, st =state))
    return 0
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Update_queue_table_to(state,setup_id,task_id,time):
    #print (setup_id)
    #print (state)
    #print time
    conn = sqlite3.connect(db_name)
    c = conn.cursor()
    l = Lock()
    l.acquire()
    try:
       c.execute("UPDATE %s SET status = ?,setup_id = ?,dispatch_time = ? WHERE task =?"%(queue_table), (state, setup_id, time, task_id))
    except sqlite3.OperationalError:
           logging.error('DB UPDATE Error')
    except: 
       if console_print:
          print "DB UPDATE Error,Check %s table and Setup ID:%s"%(queue_table,setup_id)
       if logger.isEnabledFor(logging.DEBUG):
          logging.error('DB UPDATE Error,Check %s table and Setup ID:%s',queue_table,setup_id)
    conn.commit()
    l.release()
    conn.close()
    if logger.isEnabledFor(logging.DEBUG):
       logging.info("task_id {bid} status updated to {st}".\
           format(bid = task_id, st =state))

#-------------------------------------------------------------------------------------------------------------------------------#
def Update_duration_to_queue_table(state,setup_id,task_id,duration,finish_time,total_duration):
    #print (setup_id)
    #print (state)
    #print task_id
    #print duration
    conn = sqlite3.connect(db_name)
    c = conn.cursor()
    l = Lock()
    l.acquire()
    try:
       c.execute("UPDATE %s SET status = ?,setup_id = ?,duration= ?,finish_time = ?,ttime = ? WHERE task =?"%(queue_table), (state, setup_id, duration, finish_time, total_duration, task_id))
    except sqlite3.OperationalError:
           logging.error('DB UPDATE Error')
    except:
       if console_print:
          print "DB UPDATE Error,Check %s table and Setup ID:%s"%(queue_table,setup_id)
       if logger.isEnabledFor(logging.DEBUG):
          logging.error('DB UPDATE Error,Check %s table and Setup ID:%s',queue_table,setup_id)
    conn.commit()
    l.release()
    conn.close()
    if logger.isEnabledFor(logging.DEBUG):
       logging.info("task_id {bid} status updated to {st}".\
           format(bid = task_id, st =state))


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Get_Testing_Task_ids():
    if console_print:
       print " Get Testing task IDs"
    column_to_read = 'task'
    column_id = 'status'
    column_value = 'testing'
    Read = Read_database()
    testing_task_ids= Read.read_query(db_name,queue_table,column_to_read,column_id,column_value)
    #print "Testing task ids are:%s"%(testing_task_ids)
    return testing_task_ids 
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Get_ip_url(testing_setup_id,url_state):
    if testing_setup_id != '' and url_state != '':
       column_to_read = 'ipaddress'
       column_to_read2 = url_state
       column_id = 'setup_id'
       column_value = testing_setup_id
       Read = Read_database()
       val1,val2 = Read.two_value_query(db_name,setup_table,column_to_read,column_to_read2,column_id,column_value)
       #print val1,val2 

       ip = val1 
       url = val2 
       return ip,url
    else:
      if logger.isEnabledFor(logging.DEBUG):
         logging.info('Improper testing setup id and url found')
      return 1,1      
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Get_polling_data(ip,url):
    # create url using ip and html
    url_prefix = 'wget http://'
    url_postfix = url
    url = str(url_prefix + ip + url_postfix)
    if console_print:print url
    # Call a function to get the device status using url
    try:
       os.system('rm auto_status.cg*')
    except:
           if console_print:
              print "File doesn't exists"
           if logger.isEnabledFor(logging.DEBUG):
              logging.info('File doesnot exists ')
    try:
        #res = os.system(url)
        st,out=commands.getstatusoutput(url)
        if console_print:print st,out
    except:
           get_status_error_count = get_status_error_count + 1
           if console_print:
              print "Unable to access the setup status data"
           if logger.isEnabledFor(logging.DEBUG):
              logging.info('Unable to access the Setup Status data ')
              logger.debug('Url: %s ',str(url))
              logger.debug('Output: %s ',str(out))
              return 1
    try:
       data = open('auto_status.cgi')
       data= data.read()
    except:
         if logger.isEnabledFor(logging.DEBUG):
            logging.info('Setup status File doesnot exists, Verify the reachability of the setup')
         return 1

    setup_status = data.strip()
    #print setup_status
    return setup_status 
#----------------------------------------------------------------------------------------#
def Get_board_id(testing_setup_id,testing_task_id):
    board_list_file = "/testserver/db/setup_info/%s/board_list.txt"%(testing_task_id)
    if os.path.exists(board_list_file):
       with open(board_list_file, 'r')as f:
         with open(board_list_file, 'r')as s:
            boardlist = [line.split(None, 1)[0] for line in f]
            wanlist = [line.split(None, 3)[2] for line in s]
    #print "board id is: %s"%(boardlist)
    return boardlist,wanlist

     
#------------------------------------------------------------------------------------------------------------------------#

def Get_result_from_setup(testing_setup_id,testing_task_id,setup_status):
    print "Copy the Result files to Test Server" 
    # if the get_result fails, Need to handle the case specifically
    ip,url = Get_ip_url(testing_setup_id,'url_create_dir')
    board_id,wanlist = Get_board_id(testing_setup_id,testing_task_id)
    #print wanlist
    direct = "/testserver/db/log/task/%s/"%(testing_task_id)
    # Creating directory in local path
    if not os.path.exists(direct):
           os.makedirs(direct)
           print "Local Directory created on test server"
           time.sleep(3) 
    else:
          print "Directory Already exists on TS"
    for i in range(0,len(board_id)):
    #for bid in board_id:
      #for each in wanlist:   
        #i = board_id.index(bid)
        
        files = ["log_console_%s.txt"%(wanlist[i]),"log_%s.txt"%(wanlist[i]),"result_%s.htm"%(wanlist[i])]
        #files = ["log_console_%s.txt"%(each),"log_%s.txt"%(each),"result_%s.htm"%(each)]
        #print files
        for filename in files:
            remote_dir = "/tftpboot/" + "/task/%s/%s/%s"%(testing_task_id,board_id[i],filename)
            #print remote_dir
            local_dir = "/testserver/db/log/task/%s/%s"%(testing_task_id,filename)
            #print local_dir
            url = "curl -o %s -F file_dir='%s'  http://%s/cgi-bin/auto_download.cgi"%(local_dir,remote_dir,ip)
            #print url
            st,out=commands.getstatusoutput(url)
            output = str(out)
            logger.debug('Url: %s ',str(url))
            logger.debug('Output: %s ',str(output))

            timeout = output.find("Connection")
            if timeout != -1:
                if console_print:
                    print "Connection timed out!!!"
                if logger.isEnabledFor(logging.DEBUG):
                   logging.info('Connection timed out!!!')
                get_result_error_count = get_result_error_count + 1
                return 1
            if os.path.exists(local_dir):
               with open(local_dir, 'r') as f:
                 statinfo = os.stat(local_dir)
                 size = statinfo.st_size
                 first_line = f.readline()
                 if first_line == 'Fail' and size < 10:
                    print "%s is Failed to Download"%(filename)
                    if logger.isEnabledFor(logging.DEBUG):
                        logging.info('%s is Failed to Download',filename)
                 else:
                   print "%s Downloaded Succesfully"%(filename)
                   if logger.isEnabledFor(logging.DEBUG):
                        logging.info('%s Downloaded Succesfully',filename)
            else:
              print "file not downloaded"
              if logger.isEnabledFor(logging.DEBUG):
                        logging.info('%s is Failed to Download',filename)
              return 1    
    return 0


#------------------------------------------------------------------------------------------------------------------------#
def Clear_test_configs(ip,testing_task_id):
    print "Remove task Dir on the setup"
    dir_remove = "/testserver/db/setup_info/%s"%(testing_task_id)
    if os.path.exists(dir_remove):
       shutil.rmtree(dir_remove) 
    return 0 
#-------------------------------------------------------------------------------------------------------------------------#
def Get_time_tag(testing_task_id,time_to_read):
    column_to_read = time_to_read
    column_id = 'task'
    column_value = testing_task_id
    column_id2 = 'status'
    column_value2 = 'testing'
    #print db_name,queue_table,column_to_read,column_id,column_value,column_id2,column_value2
    Read = Read_database()
    time= Read.fetchone_query(db_name,queue_table,column_to_read,column_id,column_value,column_id2,column_value2)
    #if value is none need to taken care
    #print time  
    time = str(time)   
    dispatch_time= datetime.datetime.strptime(time,"%Y-%m-%d %H:%M:%S") 
    #print dispatch_time
    return dispatch_time
 

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

def Move_completed_task_update_history(testing_task_id,results):
    conn = sqlite3.connect(db_name)
    c = conn.cursor()
    try:
      c.execute("INSERT INTO %s SELECT * FROM %s WHERE task = '%s' and status = '%s'"%(history_table,queue_table,testing_task_id,results))
      time.sleep(2)
      c.execute("DELETE FROM %s WHERE task = '%s' and status = '%s'"%(queue_table,testing_task_id,results))
    except:
        if logger.isEnabledFor(logging.DEBUG):
           logging.error('DB UPDATE Error,Check %s table and Task ID:%s',queue_table,testing_task_id)
        conn.commit()
        conn.close()   
        return 1
    conn.commit()
    conn.close()
    if logger.isEnabledFor(logging.DEBUG):
       logging.info("task_id {bid} status updated to {st}".\
           format(bid = testing_task_id, st ='Completed'))
    return 0
#--------------------------------------------------------------------------------------------------------------------------------------------#
def Get_user_details(testing_task_id):
    if testing_task_id != '':
       #print "Task:%s"%(testing_task_id)
       column_to_read = 'user'
       column_id = 'task'
       column_value = testing_task_id
       column_to_read2 = 'email'
       Read = Read_database()
       #print db_name,history_table,column_to_read,column_to_read2,column_id,column_value
       username,email = Read.two_value_query(db_name,history_table,column_to_read,column_to_read2,column_id,column_value)
       #print username,email 
       return username,email
    else:
      if logger.isEnabledFor(logging.DEBUG):
         logging.info('Improper Testing Task ID found')
      return 1
#--------------------------------------------------------------------------------------------------------------------------------------------#
def lcount(keyword, fname):
      with open(fname, 'r') as fin:
         return sum([1 for line in fin if keyword in line])


#--------------------------------------------------------------------------------------------------------------------------------------------#
def Send_Mail(testing_task_id,testing_setup_id,setup_status,total,Pass,Fail):
    username,email = Get_user_details(testing_task_id)
    console_log = "/testserver/db/log/task/%s/log_console_eth.txt"%(testing_task_id)
    log = "/testserver/db/log/task/%s/log_eth.txt"%(testing_task_id)
    #print log,console_log
    if os.path.isfile(console_log):
          console_log = "/testserver/db/log/task/%s/log_console_eth.txt"%(testing_task_id)
    else:
       console_log = ''
    if os.path.isfile(console_log):
        log = "/testserver/db/log/task/%s/log_eth.txt"%(testing_task_id)
    else:
       log = ''

    report_file = "/testserver/db/log/task/%s/Report.txt"%(testing_task_id)
    #print report_file
    '''def lcount(keyword, fname):
      with open(fname, 'r') as fin:
         return sum([1 for line in fin if keyword in line])
    '''
    with io.FileIO(report_file, "w") as file:
               file.write("Hi %s,"%(username))
               file.write("\n\n")
               file.write("\t")
               file.write(" For detailed Test Report, refer to http://%s/testserver/results.php?result=result&taskid=%s"%(testserver_ip,testing_task_id))
               file.write("\n\n\n")
               file.write("Regards")
               file.write("\n")
               file.write("BSP Automation Server")
    if setup_status == "Errored":
             "Result of Task %s : %s,Test setup_id : %s"%(testing_task_id,"Test setup issue",testing_setup_id)
    if setup_status == "Completed":
      if total == Pass and total != 0 and Pass !=0:
         subject = "Result of Task %s : %s "%(testing_task_id,"Pass")
      else:
         subject = "Result of Task %s : Pass:%s\ Fail:%s "%(testing_task_id,Pass,Fail)
      
    '''
    file1 = "/testserver/db/log/task/%s/result_eth.htm"%(testing_task_id)
    #print file1
    key1 = '<td>ok'
    key2 = '>Failed'
    key3 = '>fail<'
    statinfo = os.stat(file1)
    size = statinfo.st_size
    if os.path.isfile(file1) and size > 4:
          Pass = lcount(key1, file1)
          b = lcount(key2, file1)
          e = lcount(key3, file1)
          Fail = b+e
          #print Pass,Fail
          if Pass == 0 and Fail != 0:
             subject = "Result of Task %s : %s "%(testing_task_id,"Fail")
          if Fail == 0 and Pass != 0:
             subject = "Result of Task %s : %s "%(testing_task_id,"Pass")
             Pass = str(Pass)
             Fail = str(Fail)
          else:
             subject = "Result of Task %s : Pass:%s\ Fail:%s "%(testing_task_id,Pass,Fail)
          #print subject
          if setup_status == "Errored":
             "Result of Task %s : %s,Test setup_id : %s"%(testing_task_id,"Test setup issue",testing_setup_id)
    else:
       print "Test Report html  file not Generated"
       if logger.isEnabledFor(logging.DEBUG):
          logger.debug('Test Report html file not Generated')
       subject = "Result of Task %s : %s "%(testing_task_id,"Fail")
    ''' 
    res = os.path.exists(report_file)
    if res == True:
       url_string = "mutt -s '%s' %s < %s"%(subject,email,report_file)
       #url_string = "mutt -s '%s' %s -a %s -a %s < %s"%(subject,email,console_log,log,report_file)
       st,out=commands.getstatusoutput(url_string)
       #print st,out
       output = str(out)
       fail = output.find("No such file")
       if fail != -1:
          print "Test Report E-mail Notification failed"
          if logger.isEnabledFor(logging.DEBUG):
             logger.debug('Test Report E-mail Notification failed')
          return 1
       else:
          print "Test Report E-mail Notification Sent Successfully"
          if logger.isEnabledFor(logging.DEBUG):
             #logger.debug('Pass:%s, Fail: %s',Pass,Fail)
             logger.debug('Test Report E-mail Notification Sent Successfully')
          return 0
    else:
       print "Test Report file not Generated"
       if logger.isEnabledFor(logging.DEBUG):
          logger.debug('Test Report file not Generated')
       return 1
     


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Make_setup_free(testing_setup_id,testing_task_id):
    #print testing_setup_id
    if testing_setup_id != 0:
        #print "call function to get the IP and url details"
        ip,url = Get_ip_url(testing_setup_id,'url_free')
        #print ip,url 
        #print "Call function to run curl command to make setup free"    
        url_string_prefix = "curl --request POST 'http://"
        url_string_postfix = " HTTP/1.1' --data 'submit=submit'"
        url_string = str(url_string_prefix  + ip + url +url_string_postfix)
        #print (url_string)
        # Need to validate the curl command failure or pass activity
        try:
          stat = os.system(url_string)
          #print stat
          logger.debug('Url: %s ',str(url_string))
          logger.debug('Output: %s ',str(stat))
        except:
           if console_print:
              print "Unable to make the setup free, Current Task is not yet completed"
           make_free_error_count = make_free_error_count + 1
           if make_free_error_count > 3:
              Send_Mail(testing_task_id,testing_setup_id,'Errored',0,0,0)      
           if logger.isEnabledFor(logging.DEBUG):
              logging.error('Unable to make the setup free, Current Task is not yet completed')
              return 1 #Make free curl command is failing, returning to the calling function with out making changes to setup , So setup status remains finished
        reserve_flag,current_status = Get_reserve_flag_state(testing_setup_id)
        #print reserve_flag,current_status
        time.sleep(10) #can be removed
        Update_Test_setup_table_to('Free',testing_setup_id,None)
        dispatch_time = Get_time_tag(testing_task_id,'dispatch_time') 
        submit_time = Get_time_tag(testing_task_id,'submit_time') 
        print "Dispatch Time: %s"%(dispatch_time)
        t = datetime.datetime.now()
        t= t.replace(microsecond=0)
        finish_time = str(t.strftime('%Y-%m-%d %H:%M:%S'))
        print "Finished Time: %s"%(t)
        duration = t - dispatch_time
        run_time_minutes = duration.seconds/60
        #print run_time_minutes
        print "Duration: %s"%(duration)
        duration =str(duration)
        logger.debug('Test Duration: %s',duration)
        total_duration = t - submit_time
        print "Total_Duration: %s"%(total_duration)
        total_duration =str(total_duration)
        #Get pass and fail count
        wan_list = Get_wan_list(testing_task_id)
        if wan_list ==[None]:
                print " Empty wan list"
        Pass = Fail = 0
        for each in wan_list:
             file1 = "/testserver/db/log/task/%s/result_%s.htm"%(testing_task_id,each)
             #print file1
             key1 = '<td>ok'
             key2 = '>Failed'
             key3 = '>fail<'
             try:
               statinfo = os.stat(file1)
               size = statinfo.st_size
               if os.path.isfile(file1) and size > 4:
                  a  = lcount(key1, file1)
                  b = lcount(key2, file1)
                  e = lcount(key3, file1)
                  f = b+e
                  Pass += a
                  Fail += f
                  print Pass,Fail
               else:
                 continue
             except:
                 continue 
        total = 0
        for each in wan_list:
                  file1 = "/testserver/db/testcase/testcase_list_%s.txt"%(each)
                  key1 = 'ts_bsp'
                  c  = lcount(key1, file1)
                  total += c
        #print total
        Fail = total - Pass
        if (Pass != 0 and Fail == 0 and Pass == total):
            r = '<font color=green><b>%s/%s</b></font>'%(Pass,Fail)
        if (Fail!= 0):
           r = '<font color=red><b>%s/%s</b></font>'%(Pass,Fail)
        if (Pass == Fail == 0):
             r = '<font color=red><b>No Report</b></font>'
        results = r
        print results
        results = str(results)  
        Update_duration_to_queue_table(results,testing_setup_id,testing_task_id,duration,finish_time,total_duration)
        #" Call function to Delete the completed task from the queue and update the completed task information in history table"
        Move_completed_task_update_history(testing_task_id,results)
        # Call a function clear and delete the task directory from the setup
        res = Clear_test_configs(ip,testing_task_id)
        Send_Mail(testing_task_id,testing_setup_id,'Completed',total,Pass,Fail)
        print "Task ID : %s is Completed the Execution \n"%(testing_task_id)
        print "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    return 0 

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Get_Setup_Status(testing_task_id):
    #" Call a function to get the setup ids"
    column_to_read = 'setup_id'
    column_id = 'status'
    column_value = 'testing'
    column_id2 = 'task'
    column_value2 = testing_task_id 
    Read = Read_database() 
    testing_setup_id  = Read.fetchone_query(db_name,queue_table,column_to_read,column_id,column_value,column_id2,column_value2)
    #print " Testing setup id:%s"%(testing_setup_id)
    #print " Testing task id:%s"%(testing_task_id)
    if testing_setup_id != 0:
        #print "call function to get the IP and url details" 
        ip,url = Get_ip_url(testing_setup_id,'url_status')    
        if ip == 1 and url == 1:
           if logger.isEnabledFor(logging.DEBUG):
              logging.error('IP and URL data improper')
           return 1,1   
        #print ip,url
        #print "call a function to polling device using ip and url"
        #print "Running task : %s"%(testing_task_id)
        result = Get_polling_data(ip,url)
        # "Need to handle the device polling failures"
        if result == 1:
           if console_print:
              print "Device polling failed and device not accessible"
           if logger.isEnabledFor(logging.DEBUG):
              logging.error('Device polling failed and device not accessible')    
           return 1,1
           
        setup_status = result 
        return setup_status,testing_setup_id
    else:
      
      if console_print:
         print " Improper dispatch " 
         print "The setup value is:%s , Check the waiting queue for the task_id : %s"%(testing_setup_id,testing_task_id)
      Update_queue_table_to('waiting',None,testing_task_id,None) 
      return 1,1
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------##Tempory function to call the dispatch from CGI
def Dispatch_curl_command(setup_id,task_id):
    url_state = 'url_dispatch'
    ip,url = Get_ip_url(setup_id,url_state)
    if ip == 1 and url == 1:
           if logger.isEnabledFor(logging.DEBUG):
              logging.error('IP and URL data improper')
           return 1
    url_prefix = "curl -o result.cgi --request POST 'http://"
    url_postfix = " HTTP/1.1' --data 'taskid="
    url_postfix2= "&submit=submit'"
    task_id = str(task_id)
    url_string = str(url_prefix  + ip + url + url_postfix + task_id + url_postfix2)
    time.sleep(10)
    local_file = 'result.cgi'
    try:
       os.system("rm result.cgi")
    except: 
       if console_print:
          print "No result file, new one will be created"
       
    try:
        st,out=commands.getstatusoutput(url_string)
        if console_print:
           print (url_string)
           os.system("cat result.cgi")
    except:
       if console_print:
          print "Unable to dispatch the curl command from CGI, Make sure the Device is free"
       submit_task_error_count = submit_task_error_count + 1
       if logger.isEnabledFor(logging.DEBUG):
          logging.info('Unable to dispatch the curl command from CGI, Make sure the Device is free')
       return 1
    print "\n"
    #time.sleep(3)
    if console_print:
      print "st val:%s and out val %s"%(st,out)
    output = str(out)
    logger.debug('Url: %s ',str(url_string))
    logger.debug('Output: %s ',str(output))

    timeout = output.find("Connection")
    if timeout != -1:
              if console_print:
                 print "Connection timed out!!!"
              if logger.isEnabledFor(logging.DEBUG):
                 logging.info('Connection timed out!!!')
              submit_task_error_count = submit_task_error_count + 1
              return 1

    #print "CUrl response %s"%(st)
    try:
      with open(local_file, 'r') as f:
         first_line = f.readline()
         if first_line == 'fail':
            if console_print:
               print " Curl dispatch command is failed and dispatch unsuccessful"
            if logger.isEnabledFor(logging.DEBUG):
               logging.info('Curl dispatch command is failed and dispatch unsuccessful')
            try:
               os.system("rm result.cgi")
            except:
                if console_print:
                   print "unable to delete response file"
            return 1
         elif first_line == 'ok':
             if console_print:
                print "Dispatch curl command success"
             if logger.isEnabledFor(logging.DEBUG):
                logging.debug('Dispatch curl command success')
             try:
                os.system("rm result.cgi")
             except:
                 if console_print:
                    print "unable to delete response file"
             return 0
    except:
       if console_print:
         print "Unable to dispatch the curl command from CGI, Make sure the Device is free"
       if logger.isEnabledFor(logging.DEBUG):
          logging.info('Unable to dispatch the curl command from CGI, Make sure the Device is free')
       return 1 


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Delete_the_improper_task_queue(task_id):
    conn = sqlite3.connect(db_name)
    c = conn.cursor()
    c.execute("DELETE FROM %s WHERE task = '%s' and status = 'waiting'"%(queue_table,task_id))
    conn.commit()
    conn.close()
    if logger.isEnabledFor(logging.DEBUG):
       logging.info("task_id %s is Deleted due to improper entries"%(task_id))
    return 0
#-------------------------------------------------------------------------------------------------------#
def Get_image_path(task_id,model_name_of_task):
    #print task_id,model_name_of_task
    column_to_read = 'image'
    column_id = 'task'
    column_value = task_id
    column_id2 = 'model'
    column_value2 = model_name_of_task
    Read = Read_database()
    image_path  = Read.fetchone_query(db_name,queue_table,column_to_read,column_id,column_value,column_id2,column_value2)
    #print image_path
    if image_path == [] or None:
       print "the image name is not proper"
    return image_path

#------------------------------------------------------------------------------------------------------------#
def Get_Testtype_subtype(task_id):
    if task_id != '':
       column_to_read = 'ttype'
       column_to_read2 = 'stype'
       column_id = 'task'
       column_value = task_id
       Read = Read_database()
       val1,val2 = Read.two_value_query(db_name,queue_table,column_to_read,column_to_read2,column_id,column_value)
       print val1,val2
       val1 = str(val1)
       val2 = str(val2)
       val1 = val1.lower()
       val2 = val2.lower()
       testtype = val1
       subtype = val2
       return testtype,subtype
    else:
      if logger.isEnabledFor(logging.DEBUG):
         logging.info('Improper task id found')
      return 1,1



#------------------------------------------------------------------------------------------------------------#
def Get_testcase_file(task_id):
    #Get the testcase list file name using task id 
    column_to_read = 'tc_grp'
    column_id = 'task'
    column_value = task_id
    Read = Read_database()
    testcase_list = Read.read_query(db_name,queue_table,column_to_read,column_id,column_value)
    #print testcase_list
    testcase_list = testcase_list[0]
    #print testcase_list
    if testcase_list == []:
       if logger.isEnabledFor(logging.INFO):
                   logging.error('Testcase_list is empty')
       return 1
    if not testcase_list.endswith('.txt'):
           testcase_list = testcase_list + ".txt"
    #print testcase_list
    test_case_file= "/testserver/db/testcase/%s"%(testcase_list)
    res = os.path.isfile(test_case_file)
    #print res
    if res == False:
       return 2
    test_group_file = test_case_file
    return test_group_file


#------------------------------------------------------
def Get_wan_list_per_board(setup_id,model,board_id):
      #print setup_id,model,board_id
      table_name = "models"
      column_to_read1= "eth"
      column_to_read2= "atm"
      column_to_read3 = "ptm"
      column_id = "setup_id"
      column_value= setup_id
      column_id2 = "model"
      column_value2 = model
      column_id3 = "board_id" 
      column_value3 = board_id
      Read = Read_database()
      result = Read.read_mutli(db_name,model_table,column_to_read1,column_to_read2,column_to_read3,column_id,column_value,column_id2,column_value2,column_id3,column_value3)
      #print result
      if result == []:
         if logger.isEnabledFor(logging.INFO):
          logging.info('WAN Mode List is empty')
          return result
         if console_print:
           print result
      wan_list_per_board = []
      if result[0]== 1:
         wan_list_per_board.append('eth')
      if  result[1]== 1:
         wan_list_per_board.append('atm')
      if result[2] == 1:
         wan_list_per_board.append('ptm')
      if console_print:
         print " Wan modes supported in the model %s are %s"%(model,wan_list_per_board)
      return wan_list_per_board


#----------------------------------------------------------------------------------------------------------------------------------------------#
def Get_Board_id_per_mode(setup_id,model,wan_mode):
      #print setup_id,model,wan_mode
      table_name = "models"
      column_to_read = "board_id"
      column_id = "setup_id"
      column_value= setup_id
      column_id2 = "model"
      column_value2 = model
      column_id3 = wan_mode
      column_value3 = 1
      Read = Read_database()
      result = Read.fetchone_query2(db_name,table_name,column_to_read,column_id,column_value,column_id2,column_value2,column_id3,column_value3)
      #print result
      if result == None:
         result = ""
         print "result is none"
      result = str(result) 
      return result
 
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Send_testcase_config_file(setup_id,task_id,board_id_list_file,board_id,model_name_of_task):
    #" call the curl command to send the files:"
    url_state = 'url_create_dir'
    #image_path = '201612071307451_rekha_GRX350_GW_HE_VDSL_LTE'
    image_path = Get_image_path(task_id,model_name_of_task)
    IP,url = Get_ip_url(setup_id,url_state)
    #print IP,url,task_id
    LOCAL_LOCATION = "/tftpboot/%s/"%(image_path)
    REMOTE_LOCATION = "/tftpboot/task/%s/"%(task_id)
    #print REMOTE_LOCATION
    test_group_file = Get_testcase_file(task_id)
    testtype,subtype = Get_Testtype_subtype(task_id)
    board_list,wanlist = Get_board_id(setup_id,task_id)
    board_id = board_list
    #print testtype,subtype,board_list,wanlist,test_group_file   
   
 
    if 'eth' in wanlist and testtype == 'smoke' or testtype == 'full' and subtype == 'standard':
       ts_eth = "/testserver/db/testcase/testcase_list_eth.txt"
    else:
       ts_eth = ""
    if 'atm' in wanlist and testtype == 'smoke' or testtype == 'full' and subtype == 'standard':
       ts_atm  = "/testserver/db/testcase/testcase_list_atm.txt"
    else:
       ts_atm = ""
    if 'ptm' in wanlist and testtype == 'smoke' or testtype == 'full' and subtype == 'standard':
       ts_ptm = "/testserver/db/testcase/testcase_list_ptm.txt"
    else:
       ts_ptm = ""
    if test_group_file == 1 or test_group_file == 2:
       if console_print:
          print "Default test case file"
       test_group_file = "/testserver/db/testcase/testcase_list_default.txt"
       with open(test_group_file) as f:
            lines = f.readlines()
            #print lines
            if ts_eth:
               with open(ts_eth, "w") as f1:
                 f1.writelines(lines)
                 f1.close()
            if ts_atm:
                with open(ts_atm, "w") as f2:
                     f2.writelines(lines)
                     f2.close()
            if ts_ptm:
                 with open(ts_ptm, "w") as f3:
                       f3.writelines(lines)
                       f3.close()
            f.close()
    else:
       with open(test_group_file) as f:
            lines = f.readlines()
            #print lines
            if ts_eth:
               with open(ts_eth, "w") as f1:
                 f1.writelines(lines)
                 f1.close()
            if ts_atm:
                with open(ts_atm, "w") as f2:
                     f2.writelines(lines)
                     f2.close()
            if ts_ptm:
                 with open(ts_ptm, "w") as f3:
                       f3.writelines(lines)
                       f3.close()
            f.close()
    ip = IP
    res = os.path.exists(board_id_list_file)
    if res == False:
       return 4
    res = os.path.exists("%s/%s"%(LOCAL_LOCATION,'u-boot-nand.bin'))
    if res == False:
       image_file_list = ['fullimage.img']
       for each in image_file_list:
           res1 = os.path.exists("%s/%s"%(LOCAL_LOCATION,each))
           if res1 == False:
              return 2
       var = []
       url_string2 = ["curl -F filename=@'%s/fullimage.img' -F file_dir='%s' http://%s/cgi-bin/auto_upload.cgi"%(LOCAL_LOCATION,REMOTE_LOCATION,ip), "curl -F filename=@'%s' -F file_dir='%s' http://%s/cgi-bin/auto_upload.cgi"%(board_id_list_file,REMOTE_LOCATION,ip)]
    else:
        image_file_list = ['fullimage.img','u-boot-nand.bin','gphy_firmware.img','uImage_bootcore']
        for each in image_file_list:
             res = os.path.exists("%s/%s"%(LOCAL_LOCATION,each))
             #print res	
             if res == False:
                return 2
        var = []
        url_string2 = ["curl -F filename=@'%s/gphy_firmware.img' -F file_dir='%s' http://%s/cgi-bin/auto_upload.cgi"%(LOCAL_LOCATION,REMOTE_LOCATION,ip), "curl -F filename=@'%s/u-boot-nand.bin' -F file_dir='%s' http://%s/cgi-bin/auto_upload.cgi"%(LOCAL_LOCATION,REMOTE_LOCATION,ip), "curl -F filename=@'%s/fullimage.img' -F file_dir='%s' http://%s/cgi-bin/auto_upload.cgi"%(LOCAL_LOCATION,REMOTE_LOCATION,ip), "curl -F filename=@'%s/uImage_bootcore' -F file_dir='%s' http://%s/cgi-bin/auto_upload.cgi"%(LOCAL_LOCATION,REMOTE_LOCATION,ip), "curl -F filename=@'%s' -F file_dir='%s' http://%s/cgi-bin/auto_upload.cgi"%(board_id_list_file,REMOTE_LOCATION,ip)]
    for i in range(0,len(board_id)):
       str1 = "curl -F filename=@'/testserver/db/testcase/testcase_list_%s.txt' -F file_dir='%s/%s' http://%s/cgi-bin/auto_upload.cgi"%(wanlist[i],REMOTE_LOCATION,board_id[i],ip)
       var.append(str1)
       #print var
       final = url_string2 + var
       if console_print:print final
       for each in final:
         try:
           status,output=commands.getstatusoutput(each)
           #print status,output
           #logger.debug('Url: %s ',str(each))
           #logger.debug('Output: %s ',str(output))

           fail = output.find("curl: Can't open")
           timeout = output.find("Connection")
           if fail != -1:
              if logger.isEnabledFor(logging.DEBUG):
                 logging.error('Unable to copy the config files')
                 logger.debug('Url: %s ',str(each))
                 logger.debug('Output: %s ',str(output))
              return 1
           if timeout!= -1:
              if console_print:
                 print "Connection timed out!!!"
                 if logger.isEnabledFor(logging.DEBUG):
                    logger.debug('Url: %s ',str(each))
                    logger.debug('Output: %s ',str(output))
                 create_dir_error_count = create_dir_error_count + 1
                 return 3
         except:
           if console_print:
              print "Unable to copy the config files"
           if logger.isEnabledFor(logging.DEBUG):
              logging.error('Unable to copy the config files')
           return 1
    time.sleep(3)
    if logger.isEnabledFor(logging.DEBUG):
       logging.info('Image and setup configurations copied sucessfull')
    if console_print:
           print"File copied successfully to the test Setup: %s"%(setup_id)
    return 0

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
def Create_Task_Directory(task_id,setup_id,board_id):
    ip,url = Get_ip_url(setup_id,'url_create_dir')
    #print ip,url
    dname = "%s"%(task_id)
    username = 'dccom'
    password = 'dccom'
    global create_dir_error_count
    #Creating the dir in remote machine
    url = 'curl -o mkd.cgi -k -Q "MKD /tftpboot/task/%s/" --ftp-ssl --ftp-pasv -u "%s:%s" ftp://%s/'%(dname,username,password,ip)
    url2 = 'curl -o mkd.cgi -k -Q "MKD /tftpboot/task/%s/%s/" --ftp-ssl --ftp-pasv -u "%s:%s" ftp://%s/'%(dname,board_id,username,password,ip)
    url3 = "curl -Q '-SITE UMASK 777' -T '/tftpboot/task/%s/%s/' 'ftp://%s:%s@%s'"%(dname,board_id,username,password,ip)
    print url
    print url2
    print url3
    try:
       #os.system(url)
       status,output=commands.getstatusoutput(url)
       os.system(url2)
       os.system(url3)
       output = str(output)
       logger.debug('url: %s ',str(url))
       logger.debug('Output: %s ',output)
       fail = output.find("curl: (21) QUOT command failed with 550")
       timeout = output.find("Connection")       
       print status,output
       if timeout!= -1:
           if console_print:
               print "Connection timed out!!!"
           create_dir_error_count = create_dir_error_count + 1
           return 1
       elif fail != -1:
           if console_print:
             print "Directory task_%s Already Exists in Setup"%(task_id)
           #time.sleep(10)
       else : 
           if console_print:
             print "Directory task_%s created successfully"%(task_id)
           direct = "/testserver/db/log/task/%s/"%(task_id)
           # Creating directory in local path
           if not os.path.exists(direct):
               os.makedirs(direct)
               print "Local Directory created on test server"
           else: 
              print "Directory Already exists on TS"
       if logger.isEnabledFor(logging.DEBUG):
          logging.info("Test ID Directory %s is created on Setup ID: %s",str(task_id),str(setup_id)) 
       return 0 
    except:
        print "Make dir failed"
        create_dir_error_count = create_dir_error_count + 1
        if logger.isEnabledFor(logging.DEBUG):
           logger.debug('Url: %s ',str(url))
           logging.error('Unable to create directory on setup')
        return 1
    
#--------------------------------------------------------------------------------------#
def Check_task_id_in_waiting_task_list(task_id):
    column_to_read = 'task'
    column_id = 'task'
    column_value = task_id
    column_id2 = 'status'
    column_value2 = 'waiting'
    Read = Read_database()
    task= Read.fetchone_query(db_name,queue_table,column_to_read,column_id,column_value,column_id2,column_value2)
    if task == []:
       return 1
    #if console_print:print "Model name for the task id : %s is %s"%(task_id, model_name_of_task)
    return 0 
#-----------------------------------------------------------------------------------------------------------------------------#
def Check_Free_setup_id_in_Free_setup_id_list(setup_id):
    column_to_read = 'setup_id'
    column_id = 'setup_id'
    column_value = setup_id
    column_id2 = 'state'
    column_value2 = 'Free'
    Read = Read_database()
    s_id= Read.fetchone_query(db_name,setup_table,column_to_read,column_id,column_value,column_id2,column_value2)
    #if value is none need to taken care
    if s_id == []:
       return 1
    #print s_id
    return 0
#---------------------------------------------------------------------------------------------------------------------------------#

def Get_board_id_list(model,setup_id):
    #Get the model list which are supported by each setup
    logging.info(" The Setup ID is : %s"%(setup_id))
    column_to_read = 'board_id'
    column_id = 'setup_id'
    column_value = setup_id
    column_id2 = 'model'
    column_value2 = model
    #can be added setup status to verify the device state
    Read = Read_database()
    board_id = Read.read_query2(db_name,model_table,column_to_read,column_id,column_value,column_id2,column_value2)
    #if console_print:print "Models supported in setup_id %s are : %s"%(setup_id,model_name_list)
    #print board_id
    return board_id

    #return 1
#----------------------------------------------------------------------------------------------------------------------------------#
def Get_count(table_name):
    column_to_read = 'setup_id'
    conn = sqlite3.connect(db_name)
    c = conn.cursor()
    c.execute("SELECT %s FROM %s"%(column_to_read,table_name))
    row = c.fetchall()
    num = list(sum(row, ()))
    conn.commit()
    conn.close()
    return num




#------------------------------------------------------------------------------------------------------------------------------------#
def Check_Reserved_setup_state():
    #function to check the reserved test setups and updated the status to free
    setup_count = Get_count('setup')
    for reserved_setup_id in setup_count:
        reserve_flag,current_status = Get_reserve_flag_state(reserved_setup_id)
        if reserve_flag == 'No' and current_status != 'testing':
           Update_Test_setup_table_to('Free',reserved_setup_id,None)
    return 0


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#Simple function for the dispatch process 
def Dispatch_Task(task_id,wan_list,model_name_of_task,Free_setup_id_list):
        logging.DEBUG = 1
        logging.INFO = 0
        if logger.isEnabledFor(logging.DEBUG):
                 logger.debug('\n\t\t Current Task ID is : %s \n',task_id)
        #Task_id Wan mode flags
        eth_task = 0
        atm_task = 0
        ptm_task = 0
        # Logic to get the wan_modes in WAN_MODE_TASK_ID_LIST
        if 'eth' in wan_list:
            eth_task = 1
        else: eth_task = 0
        if 'atm' in wan_list:
              atm_task = 1
        else: atm_task = 0
        if 'ptm' in wan_list:
              ptm_task = 1
        else: ptm_task = 0
        if console_print: print "Task WAN mode flags values for ETH,ATM,PTM : %s,%s,%s"%(eth_task,atm_task,ptm_task)
        #Check each setup id for the dispatch
        for setup_id in Free_setup_id_list:
                 #if console_print: print "Get the Model_names which the setup supports"
                 # Check reserved flag, if its yes skip the setup and move to next
                 reserve_flag,current_status = Get_reserve_flag_state(setup_id)
                 #print "REserved Flag State:%s,%s"%(reserve_flag,current_status)
                 if reserve_flag == 'Yes' and current_status == 'Free':
                    #Update_Test_setup_table_to('Reserved',setup_id,None)
                    continue
                 # Get the device ip and url 

                 # Get device poling data
                 
                 model_name_list = Get_model_name_list(setup_id)
                 if logger.isEnabledFor(logging.DEBUG):
                    logger.debug('Model_list for the Free setup ID : %s are %s',str(setup_id),str(model_name_list))
                 if console_print:print "Model_list for the setup id : %s are %s"%(str(setup_id),str(model_name_list))
                 if console_print:print "Model_Name_of_Task: %s"%(model_name_of_task)
                 eth_setup = 0
                 atm_setup = 0
                 ptm_setup = 0
                 for model in model_name_list:
                       result = model_name_of_task.find(model)
                       if result != 0:
                       #if model != model_name_of_task:
                           if console_print: print "Task Model ID: %s Does not match with setup model: %s"%(model_name_of_task,model)
                           #if logger.isEnabledFor(logging.DEBUG):
                           #   logger.info('Task Model Info Does not match with Setup Model Info') 
                           continue
                       if console_print:print "Call a function to get the wan_modes supported"
                       board_ids = Get_board_id_list(model,setup_id)
                       #print board_ids
                       #board_ids = str(board_ids)
                       if not os.path.exists(setup_info):
                               os.makedirs(setup_info)
                       wan_list_per_model = Get_wan_list_per_model(model,setup_id)
                       board_id_list_file = "/testserver/db/setup_info/%s/board_list.txt"%(task_id)
                       
                       if board_ids:
                           if logger.isEnabledFor(logging.DEBUG):
                               logger.debug('Wan List for the Model %s are %s',model,wan_list_per_model)
                           if console_print:
                                print "Wan List per Model %s"%(wan_list_per_model)
                                print "Wan List Task %s"%(wan_list)
                           #mode = 'a' if os.path.exists(board_id_list_file) else 'w'
                           mode = 'w' if os.path.exists(board_id_list_file) else 'w'
                           with io.FileIO(board_id_list_file, mode) as file:
                              if eth_task==1 and eth_setup == 0 and 'eth' in wan_list_per_model:
                                 #print eth_task,eth_setup
                                 eth_setup = 1
                                 wan_mode = "eth"
                                 Get_Board_id = Get_Board_id_per_mode(setup_id,model,wan_mode)
                                 board_id = Get_Board_id
                                 if eth_setup:
                                     file.write(board_id)
                                     file.write("\t")
                                     file.write(model)
                                     file.write("\t")
                                     file.write("eth")
                                     file.write("\t")
                                     file.write("yes")
                                     file.write("\n")
                              if atm_task==1 and atm_setup == 0 and 'atm' in wan_list_per_model:
                                 atm_setup = 1
                                 wan_mode = "atm"
                                 Get_Board_id = Get_Board_id_per_mode(setup_id,model,wan_mode)
                                 board_id = Get_Board_id
                                 if atm_setup:
                                     file.write(board_id)
                                     file.write("\t")
                                     file.write(model)
                                     file.write("\t")
                                     file.write("atm")
                                     file.write("\t")
                              	     file.write("yes")
                                     file.write("\n")
                              if ptm_task==1 and ptm_setup == 0 and 'ptm' in wan_list_per_model:
                                 ptm_setup = 1
                                 wan_mode = "ptm"
                                 Get_Board_id = Get_Board_id_per_mode(setup_id,model,wan_mode)
                                 board_id = Get_Board_id
                                 if ptm_setup:
                                     file.write(board_id)
                                     file.write("\t")
                                     file.write(model)
                                     file.write("\t")
                                     file.write("ptm")
                                     file.write("\t")
                                     file.write("yes")
                                     file.write("\n")
                       if logger.isEnabledFor(logging.DEBUG):
                          logger.debug('Board List created successfully')
                        
                          logger.debug('Setup ID %s Matching Wan list is: %s,%s,%s',setup_id,eth_setup,atm_setup,ptm_setup)
                       if console_print: print "Setup WAN mode flags values for ETH,ATM,PTM : %s,%s,%s"%( eth_setup,atm_setup,ptm_setup)
                       # Compare the WAN_MODE_TASK_ID_LIST and WAN_MODE_PER_MODEL flag if matching dispatch , else move to next setup
                       if eth_task == eth_setup and atm_task == atm_setup and ptm_task == ptm_setup:
                          #print "Ensure the Task ID: %s is still in the task waiting queue and Setup ID: %s is in Free state"%(task_id,setup_id) 
                          #waiting_task_ids = Get_Waiting_Task_ids()
                          #Free_setup_id_list = Get_free_setup_id_list()
                          check_waiting_task = Check_task_id_in_waiting_task_list(task_id)
                          check_Free_setup_id = Check_Free_setup_id_in_Free_setup_id_list(setup_id)
                          #print check_waiting_task,check_Free_setup_id
                          if check_Free_setup_id == 0 and check_waiting_task == 0:
                          #if task_id in waiting_task_ids and setup_id in Free_setup_id_list:
                             if console_print:print "Match success"                          
                             if console_print:print "Call a function to make the setup id %s to move to testing state"%(setup_id)
                             if console_print:print "Call curl dispatch function"
                             if console_print:
                                   print "Call a function to copy the Images,Testcases and Config File to Setup\n"
                                   #print setup_id,task_id,board_id_list_file,board_id
                             res = Send_testcase_config_file(setup_id,task_id,board_id_list_file,board_ids,model_name_of_task)
                             #time.sleep(15)
                             if res == 1:
                                   if logger.isEnabledFor(logging.DEBUG):
                                      logging.debug('Copying the image and setup configs process failed')
                                      Update_duration_to_queue_table('Error:Image copy Failed','',task_id,'','','')
                                   return 1
                             if res == 2:
                                   if logger.isEnabledFor(logging.DEBUG):
                                      logging.debug('Files does not exists in TFTP Dir')
                                      Update_duration_to_queue_table('Error:Files does not exists in TFTP Dir','',task_id,'','','')
                                   return 1
                             if res == 3:
                                    if logger.isEnabledFor(logging.DEBUG):
                                      logging.debug('Setup Connection timedout')
                                      Update_duration_to_queue_table('Error:Setup Connection timedout','',task_id,'','','')
                                    return 1
                             if res == 4:
                                    if logger.isEnabledFor(logging.DEBUG):
                                      logging.debug('Board_list File is not exists')
                                      Update_duration_to_queue_table('Error:Board_list File is not exists','',task_id,'','','')
                                    return 1

                             if logger.isEnabledFor(logging.DEBUG):
                                logging.debug('Copied the image and setup configs successfully')
                             result = Dispatch_curl_command(setup_id,task_id)
                             if result == 1:
                                if console_print:print "Curl dispatch failed and dispatch unsucessful"
                                if logger.isEnabledFor(logging.DEBUG):
                                   logging.debug('Curl dispatch failed for Task ID: %s and Setup ID: %s and dispatch unsucessful',task_id,setup_id)
                                Update_duration_to_queue_table('Error:Dispatch Curl Failed','',task_id,'','','')
                                return 1
                             if logger.isEnabledFor(logging.DEBUG):
                                logging.debug('Curl command sucess ')
                             l = Lock()
                             l.acquire()
                             Update_Test_setup_table_to('testing',setup_id,task_id)
                             t = datetime.datetime.now()
                             dispatch_time = str(t.strftime('%Y-%m-%d %H:%M:%S'))
                             #print dispatch_time

                             Update_queue_table_to('testing',setup_id,task_id,dispatch_time)
                             l.release()

                              

                             if logger.isEnabledFor(logging.DEBUG):
                                logger.debug('match sucess and Dispatch\n')
                             return 0
                          else:
                             if console_print:print "Dispatch unsuccessful\n"
                             if logger.isEnabledFor(logging.DEBUG):
                                logging.debug('Dispatch unsuccessful\n')
                             continue

                          if console_print:print "Once the setup and board ID is finalized, create a directory Task_Task_id_board_id on setup"
                          if console_print:print "copy the required config/testcase/required documents to the setup"
                          if console_print:print "Dispatch successful" 
                       else:
                          if logger.isEnabledFor(logging.DEBUG):
                             logging.debug('doesnot match and check next\n')
                          if console_print:print "doesn't match"
                          Update_duration_to_queue_table('Error:WAN Mode does not match','',task_id,'','','')
                          continue
        print "Unable to match any setup for task id : %s"%(task_id)
        Update_duration_to_queue_table('Error:Model Info Does not match','',task_id,'','','')
        return 1 

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Deamon function:
while (Start_deamon_flag): 
     testing_task_ids = Get_Testing_Task_ids()
     if testing_task_ids != []:
     #if task_queue_Testing != 0:
         #print " Call function to get the testing task ids from the queue"
         testing_task_ids = Get_Testing_Task_ids()
         #print testing_task_ids 
         #print "Get the number of testing task ids from the Test_Task DB" 
         for testing_task_id in testing_task_ids:
             # Get setup status using curl command form the physical setup for each task id
             #print " Call a function to get the setup status for each testing task id:"
             #print testing_task_id
             setup_status,testing_setup_id = Get_Setup_Status(testing_task_id)
             #print testing_setup_id,setup_status
             if testing_setup_id == 1 and setup_status == 1:
                if logger.isEnabledFor(logging.DEBUG):
                   logger.error('Get setup status return values are: %s,%s',testing_setup_id,setup_status)
                   print "Get setup status return values are: %s,%s"%(testing_setup_id,setup_status)
                   logger.error('Task ID is not updated in the setup table Moving to next task ID')
                   print "Task ID is not updated in the setup table Moving to next task ID"
                continue
             #print setup_status
             print "Testing Task : %s ,Setup ID: %s and Status : %s "%(testing_task_id,testing_setup_id,setup_status) 
             if setup_status == 'finished':
                #print "call Get_results function move this task to test history"
                l = Lock()
                l.acquire()
                Get_result_response = Get_result_from_setup(testing_setup_id,testing_task_id,setup_status)
                #print "Call curl command to make it free and update the setup table"
                #print testing_setup_id
                Make_setup_Free_response = Make_setup_free(testing_setup_id,testing_task_id)
                #print "Call a function to remove the finished test case from the testing queue"
                if Get_result_response != 0 and Make_setup_Free_response != 0:
                   print "Setup id : %s has some issue, please check and drop mail to admin"
                   continue
                l.release()
             if setup_status == 'free':
                if logger.isEnabledFor(logging.DEBUG):
                   logger.error('Task ID :%s and Setup ID %s in Testing state in Queue Table but Setup Status :%s Which indicates wrong dispatch or Improper setup state',testing_task_id,testing_setup_id,setup_status)
                   logger.error('Check the test stauts for this Task ID manually for confirmation')
                   print "Task ID :%s and Setup ID %s in Testing state in Queue Table but Setup Status :%s Which indicates wrong dispatch or Improper setup state"%(testing_task_id,testing_setup_id,setup_status)
                   print "Check the test stauts for this Task ID manually for confirmation"
                Update_queue_table_to('waiting',None,testing_task_id,None)
             else:
                 if console_print: print "setup_status =%s"%(setup_status)        
         time.sleep(5) #can be removed 
         if console_print: print "After the Delay Check the next Setup Status" 
          
     # Call a function to get the task_queue list
     waiting_task_ids = Get_Waiting_Task_ids() 
     if waiting_task_ids != []:      
        # Define environment variables 
        for task_id in waiting_task_ids:
             #print "Waiting Task ID :%s"%(task_id)
             #if console_print: print " Call function to get the wan_list of the waiting_task_id"

             wan_list = Get_wan_list(task_id)
             if wan_list ==[None]:
                if console_print:
                   print " Improper Wan mode information, Task ID:%s is deleted from task queue "%(task_id)
                #Call a function to delete the improper wan mode task id
                Delete_the_improper_task_queue(task_id)
                if logger.isEnabledFor(logging.DEBUG):
                   logger.debug('Improper Wan mode information, Task ID:%s is deleted from task queue ',task_id)
                continue
             #print " Call function to get the model to be tested for the task_id"
             model_name_of_task = Get_model_name_of_task(task_id)
             if model_name_of_task == None:
                if console_print:
                   print "Improper Model Information ,Task ID:%s is deleted from task queue "%(task_id) 
                #Call a function to delete the Task Id which has improper Model name
                Delete_the_improper_task_queue(task_id)
                if logger.isEnabledFor(logging.DEBUG):
                   logger.debug('Improper Model Information , Task ID:%s is deleted from task queue',task_id)
                continue
             #print model_name_of_task
             #print "Call a function to create directory for each task_id"
             # Call a function to get the setup status from the Setup Table 
             Free_setup_id_list = Get_free_setup_id_list()
             direct = "/testserver/db/setup_info/%s/"%(task_id)
             if not os.path.exists(direct):
                    os.makedirs(direct)
             if Free_setup_id_list != []:
                print "Waiting Task ID :%s"%(task_id)
                if console_print: print "Call Dispatch Function"
                if logger.isEnabledFor(logging.DEBUG):
                   logger.debug('Calling Dispatch Function With Following Data:')
                   logger.debug('WAN List:%s',wan_list)
                   logger.debug('Model Name of Task:%s',model_name_of_task)
                   logger.debug('Free Setup ID List:%s',Free_setup_id_list)
                Dispatch_Task(task_id,wan_list,model_name_of_task,Free_setup_id_list)
                #"Call function to update the Task list with setup ID details" 
                #"call a function move the task status waiting to dispatched"
                #time.sleep(15)
             else:
                if console_print:
                    print"No setup is free yet Please wait"
                Check_Reserved_setup_state()
                break
    
     else: 
        if console_print:
              print"No Task ID in waiting list"
     time.sleep(5) #can be removed
     counter = counter + 1
     if console_print:
        print "Number while loops: %s"%(counter)    
     print "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
