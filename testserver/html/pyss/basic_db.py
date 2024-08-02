#!/usr/bin/python
import sys, json, sqlite3, cgi, cgitb
import time, datetime, random
import os
from multiprocessing import Lock
from config import DB_PATH
l = Lock()

conn = sqlite3.connect(DB_PATH)
#conn = sqlite3.connect('basic_db.db')
print (conn)
print ("Opened BSP_DataBase Table successfully")
c = conn.cursor()
l.acquire()

c.execute('CREATE TABLE IF NOT EXISTS queue(task INTEGER PRIMARY KEY AUTOINCREMENT, image BLOB, model TEXT, user TEXT, email TEXT, wan TEXT, ttype TEXT, stype TEXT, meta BLOB, ltask INT, status TEXT, submit_time TEXT, dispatch_time TEXT, finish_time TEXT, duration TEXT, ttime TEXT, priority INT, setup_id INT, tc_grp BLOB)')

c.execute('CREATE TABLE IF NOT EXISTS test_history(task INTEGER PRIMARY KEY AUTOINCREMENT, image BLOB, model TEXT, user TEXT, email TEXT, wan TEXT, ttype TEXT, stype TEXT, meta BLOB, ltask INT, status TEXT, submit_time TEXT, dispatch_time TEXT, finish_time TEXT, duration TEXT, ttime TEXT, priority INT, setup_id INT, tc_grp BLOB)')

#c.execute("INSERT INTO queue(image, model, user, email, wan, ttype, stype, meta, ltask, status, submit_time, dispatch_time, finish_time, duration, ttime, priority, setup_id, tc_grp) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", ('2', '2', '2', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'))

#c.execute("INSERT INTO test_history(image, model, user, email, wan, ttype, stype, meta, ltask, status, submit_time, dispatch_time, finish_time, duration, ttime, priority, setup_id, tc_grp) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", ('2', '2', '2', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'))

c.execute('CREATE TABLE IF NOT EXISTS login(`userid` TEXT NOT NULL UNIQUE, `passwd` BLOB, PRIMARY KEY(`userid`) )')

c.execute('CREATE TABLE IF NOT EXISTS "setup" (`name` TEXT, `setup_id` INTEGER PRIMARY KEY AUTOINCREMENT, `ipaddress` BLOB, `url_status` BLOB, `url_dispatch` BLOB, `url_stop` BLOB, `url_free` BLOB, `url_create_dir` BLOB, `url_log` BLOB, `url_tc` INTEGER, `state` TEXT, `reserved` TEXT, `task` INTEGER)')

c.execute('CREATE TABLE IF NOT EXISTS "models" (`setup_id` INTEGER NOT NULL, `board_id` INTEGER NOT NULL, `model` TEXT, `eth` INTEGER, `atm` INTEGER, `ptm` INTEGER)')

c.execute('CREATE TABLE IF NOT EXISTS test_list (tc_name TEXT, tc_grp TEXT, description BLOB)')

c.execute("INSERT INTO test_list (tc_name, tc_grp, description) VALUES ('ts_bsp_telnet_dut', 'TG_BSP_ALL', 'This Test is for Telenet to DUT')")
c.execute("INSERT INTO test_list (tc_name, tc_grp, description) VALUES ('ts_bsp_http_dut', 'TG_BSP_ALL', 'This Test is for HTTP to DUT')")
c.execute("INSERT INTO test_list (tc_name, tc_grp, description) VALUES ('ts_bsp_tcp', 'TG_BSP_ALL', 'This Test is for TCP Traffic.')")
c.execute("INSERT INTO test_list (tc_name, tc_grp, description) VALUES ('ts_bsp_udp', 'TG_BSP_ALL', 'This Test is for UDP traffic.')")
c.execute("INSERT INTO test_list (tc_name, tc_grp, description) VALUES ('ts_bsp_tso_lro', 'TG_BSP_ALL', 'This Test is for TSO/LRO Counters')")

conn.commit()
print "Task added to the Queue successfully.";

l.release()
c.close()
conn.close()
