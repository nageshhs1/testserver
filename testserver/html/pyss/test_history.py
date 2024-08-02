#!/usr/bin/python
import os.path, cgi, cgitb, sqlite3
import sys, os, datetime, time
from multiprocessing import Lock
from config import DB_PATH

cgitb.enable()

op = "<td><input type=button value=Result onclick=\"ResultId(this)\"> <input type=button value=Del onclick=\"DelId(this)\"> <input type=button value=Retest onclick=\"ReTestId(this)\"> <input type=button value=TestFailOnly onclick=\"TestFailOnlyId(this)\"></td>"

l = Lock()

def lcount(keyword, fname):
    with open(fname, 'r') as fin:
         return sum([1 for line in fin if keyword in line])

conn = sqlite3.connect(DB_PATH)
c = conn.cursor()
l.acquire()

numofrows = c.execute ("SELECT COUNT(*) FROM test_history").fetchone()[0]
page ='''<script src="js/jquery-1.10.2.min.js"></script>
        <script src="js/jquery.simplePagination.js"></script>

        <script>
            jQuery(function($) {
                // i've got a little refreshed notice in there - remove it after a second
                setTimeout(function() { $("#refreshed").remove(); }, 100);
                var items = $("#content tbody tr");
                //var items = $("tbody tr");
                //var numItems = items.length;
                var numItems = %s;
                var perPage = 350;
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

c.execute ("SELECT status, task, submit_time, dispatch_time FROM test_history")
rows = c.fetchall()
for row in rows:
    taskid = row[1]
    stime = datetime.datetime.strptime(row[2], '%Y-%m-%d %H:%M:%S')
    dtime = datetime.datetime.strptime(row[3], '%Y-%m-%d %H:%M:%S')
    file1 = '/testserver/db/log/task/%s/result_eth.htm'%taskid
    #file1 = '/tftpboot/task/result_eth.htm'
    key1 = '<td>ok'
    key2 = '>Failed'
    key3 = '>fail<'
    if row[0] == 'Completed':
       if os.path.isfile(file1):
          a = lcount(key1, file1)
          b = lcount(key2, file1)
          e = lcount(key3, file1)
          f = b+e
          if (a>0 and f<=0):
             r = '<font color=green><b>%s/%s</b></font>' %(a,f)
          else :
             r = '<font color=red><b>%s/%s</b></font>' %(a,f)
       else :
          r = '<font color=red><b>No Report</b></font>' 
       c.execute ("UPDATE test_history SET status = ?, submit_time = ?, dispatch_time = ? WHERE task = ?", (r,stime,dtime,taskid))

#c.execute ("SELECT task, submit_time, user, model, wan, duration, status, setup_id, meta FROM test_history")
c.execute ("SELECT task, submit_time, dispatch_time, user, model, wan, duration, status, setup_id, meta, tc_grp FROM test_history ORDER BY task DESC limit 100")

print '<div id="pagination"></div>'
print '<table id="content" border=1>'
print '<thead>'
print '<tr><th>Task<p>Id</th> <th>Submit<p>Time</th> <th>Dispatch<p>Time</th> <th>User</th> <th>Model</th> <th>WAN <p>Mode</th> <th>Test<p> Duration</th> <th>Result<p>Pass/Fail</th> <th>Setup<p>Id</th> <th>Meta Info</th> <th>Test Gtoup</th> <th>Operation</th></tr>'
print '</thead>'
print '<tbody>'
for row in c:
    print '<tr>{}</tr>'.format(' '.join(['<td>{}</td>'.format(col) for col in row ])+op)
print '</tbody>'
print '</table>'
print page

l.release()
c.close()
conn.close()
