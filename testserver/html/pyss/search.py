#!/usr/bin/python
import re, os.path, cgi, cgitb, sqlite3
import sys, os, datetime, time, pdb
from multiprocessing import Lock
from time import gmtime, strftime
from datetime import timedelta
from config import DB_PATH

cgitb.enable()
l = Lock()
op = "<td><input type=button value=Result onclick=\"ResultId(this)\"> <input type=button value=Del onclick=\"DelId(this)\"> <input type=button value=Retest onclick=\"ReTestId(this)\"> <input type=button value=TestFailOnly onclick=\"TestFailOnlyId(this)\"></td>"

'''sys.stdout = open("zzz1.txt", "w")
print os.environ
print sys.argv[0]
print sys.argv[1]
print sys.argv[2]
print sys.argv[3]
print sys.argv[4]
print sys.argv[5]'''


if sys.argv[1]=='fromdate':
   fromdate = '2000-01-01 00:00:00'
else:
   fromdate = datetime.datetime.strptime(sys.argv[1], '%Y-%m-%d')
if sys.argv[2]=='todate':
   todate = strftime("%Y-%m-%d %H:%M:%S", gmtime())
else:
   todate = datetime.datetime.strptime(sys.argv[2], '%Y-%m-%d')
   todate = todate + timedelta(hours=23.99)
   #print todate
if sys.argv[3]=='user':
   user = '%'
else:
   user = "%" + sys.argv[3] + "%"
if sys.argv[4]=='model':
   model = '%'
else:
   model = "%" + sys.argv[4] + "%"
if sys.argv[5]=='meta':
   meta = '%'
else:
   meta = "%" + sys.argv[5] + "%"
if sys.argv[6]=='greaterthan':
   greaterthan = '%'
else:
   greaterthan = sys.argv[6]
if sys.argv[7]=='lessthan':
   lessthan = '%'
else:
   lessthan = sys.argv[7]
if sys.argv[8]=='wan':
   wan = '%'
else:
   wan = "%" + sys.argv[8] + "%"
if sys.argv[9]=='setup':
   setup = '%'
else:
   setup = "%" + sys.argv[9] + "%"

'''print fromdate
print todate
print user
print model
print meta
print greaterthan
print lessthan
print wan
print setup
print ("SELECT task, submit_time, dispatch_time, user, model, wan, duration, status, setup_id, meta FROM test_history WHERE submit_time BETWEEN ? AND ? AND user LIKE ? AND model LIKE ? AND meta LIKE ? AND (duration >= ? OR duration <= ?) AND wan LIKE ? AND setup_id LIKE ? ORDER BY task DESC",(fromdate,todate,user,model,meta,greaterthan,lessthan,wan,setup))'''

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()
c.execute ("SELECT task, submit_time, dispatch_time, user, model, wan, duration, status, setup_id, meta FROM test_history WHERE submit_time BETWEEN ? AND ? AND user LIKE ? AND model LIKE ? AND meta LIKE ? AND (duration >= ? OR duration <= ?) AND wan LIKE ? AND setup_id LIKE ? ORDER BY task DESC",(fromdate,todate,user,model,meta,greaterthan,lessthan,wan,setup))
rows_count = c.fetchall()
numofrows = len(rows_count)
page ='''<script src="js/jquery-1.10.2.min.js"></script>
        <script src="js/jquery.simplePagination.js"></script>

        <script>
            jQuery(function($) {
                // i've got a little refreshed notice in there - remove it after a second
                setTimeout(function() { $("#refreshed").remove(); }, 1000);
                var items = $("#content tbody tr");
                //var items = $("tbody tr");
                //var numItems = items.length;
                var numItems = %s;
                var perPage = 100;
                // only show the first 2 (or "first per_page") items initially
                items.slice(perPage).hide();
                // now setup pagination
                $("#pagination").pagination({
                    items: numItems,
                    itemsOnPage: perPage,
                    cssStyle: "light-theme",
                    onPageClick: function(pageNumber) { // this is where the magic happens
                        // someone changed page, lets hide/show trs appropriately
                        var showFrom = perPage * (pageNumber - 1);
                        var showTo = showFrom + perPage;
                        items.hide() // first hide everything, then show for the new page
                             .slice(showFrom, showTo).show();
                    }
                });
                // next we'll create a function to check the url fragment and change page if necessary
                // we're storing this function in a variable so we can reuse it
                var checkFragment = function() {
                    // if there's no hash, make sure we go to page 1
                    var hash = window.location.hash || "#page-1";
                    // we'll use regex to check the hash string as follows:
                    // ^            strictly from the beginning of the string (i.e. succeed "#page-3" but fail "hi!#page-3")
                    // #page-       exactly match the text "#page-"
                    // (            start a matching group (so we can access what's in these parentheses on their own)
                    //      \d      any digit ([0-9])
                    //      +       one or more of the previous literal (one or more digits)
                    // )            end the matching group
                    // $            we should now be at the end of the string - if not, then don't match (i.e. fail "#page-3hi!")
                    hash = hash.match(/^#page-(\d+)$/);
                    if(hash)
                        // the selectPage function is one of many described in the documentation
                        // we've captured the page number in a regex group: (\d+)
                        $("#pagination").pagination("selectPage", parseInt(hash[1]));
                };
                // we'll call this function whenever the back or forward buttons are pressed
                // thanks to mike o'connor for highlighting the need for this
                $(window).bind("popstate", checkFragment);

                // and we'll also call it to check right now!
                checkFragment();
            });
        </script>'''%(numofrows)

#print 'No. of Records Found:' + str(len(rows_count))

if not rows_count:
   print '<tr><strong style="font-size: 24px;">No Records Found!</strong></tr>'
else:
   print 'No. of Records Found: <font color=green face=\'verdana\' size=\'3\'><b>[' + str(len(rows_count)) + ']</b></font>'

print '<!DOCTYPE html> <html> <head>'
print '<div id="pagination"></div>'
print '<table id="content" border=1>'
print '<thead>'
print '<tr><form action="test_history.php" method="POST"><th>Task<p>Id</th> <th>Submit Time<p>Start Date<input type="text" data-date-format="yy-mm-dd" id="start_datepicker" placeholder="Select Start Date" name="fromdate" style="width: 130px;"/><p>End Date<input type="text" data-date-format="yy-mm-dd" id="end_datepicker" placeholder="Select End Date" name="todate" style="width: 130px;"/></th> <th>Dispatch<p>Time</th> <th>User<p><input type="text" placeholder="Search By User" name="user" required/></th> <th>Model<p><input type="text" placeholder="Search By Model" name="model"/></th> <th>WAN Mode<p><input type="text" style="width: 40px;" placeholder="WAN" name="wan"/></th> <th>Test Duration<p>Greater Than<input type="text" placeholder="H:MM:SS" name="greaterthan" style="width: 60px;"/><p>Less Than<input type="text" name="lessthan" placeholder="H:MM:SS" style="width: 60px;"/></th> <th>Result<p>Pass/Fail</th> <th>Setup Id<p><input type="text" placeholder="Setup" style="width: 40px;" name="setup"/></th> <th>Meta Info<p><input type="text" placeholder="Search By Meta Info" name="meta"/></th> <th>Operation<p><input type="submit" value="Search" name="action" style="height:30px;width:90px"/></th></form></tr>'
print '</thead>'
print '<tbody>'
#c.execute ("SELECT task, submit_time, dispatch_time, user, model, wan, duration, status, setup_id, meta FROM test_history WHERE submit_time BETWEEN '%s' AND '%s' AND user LIKE '%s' ORDER BY task DESC" %(fromdate,todate,user))

for row in rows_count:
    print '<tr>{}</tr>'.format(' '.join(['<td>{}</td>'.format(col) for col in row ])+op)

print '</tbody>'
print '</table>'
print page
print '</head> </html>'

l.release()
c.close()
conn.close()
