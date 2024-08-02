#!/usr/bin/python
import os,time,subprocess
ltask = '685'
retesttime = time.time()
#starttime=time.localtime()
#timeString  = time.strftime("%Y%m%d%H%M%S", starttime)
while True:
  #os.system("cd /home/dccom/bsp_test/;/home/dccom/bsp_test/CLI/bsp_test.sh")
  #os.system("rm /home/dccom/bsp_test/bin/lantiq/grx350_gw_he_vdsl_lte/temp_time")
  #time.sleep(1.0 - ((time.time() - retesttime) % 1.0))
  starttime=time.localtime()
  timeString  = time.strftime("%Y-%m-%d %H:%M:%S", starttime)
  subprocess.call("python /testserver/html/pyss/retest.py '%s' '%s'" %(ltask,timeString), shell=True)
  time.sleep(300.0 - ((time.time() - retesttime) % 300.0))
