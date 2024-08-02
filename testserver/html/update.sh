#!/bin/bash

testserver=/testserver/
html=/testserver/html/

#web server default user and group account
web_user="www-data:www-data"
cur_user="dccom:dccom"

sudo svn up
sudo chown ${web_user} /testserver/ -R
sudo chmod a+rwx /testserver/ -R
