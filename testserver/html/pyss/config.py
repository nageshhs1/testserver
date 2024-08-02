#!/usr/bin/python
import sys, json, sqlite3, cgi, cgitb
import time, datetime, random
import os
from multiprocessing import Lock

#DB_PATH = '/var/www/html/testserver/db/bsptestserver.db'
DB_PATH = '/testserver/db/bsptestserver.db'
