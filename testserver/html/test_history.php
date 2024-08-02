<?php
        session_start();
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && $_POST["del"]) {
                if(!$_SESSION['login']==session_id())  {
                echo "2Please log in to delete task"."<br>";
                echo "<a href='login.php'>Login</a>" . "<br>";
                header("location: login.php");
                exit("");
                }
        }
?>
<!DOCTYPE html>
<html >
  <head>
    <link rel="stylesheet" type="text/css" href="css\style.css">
    <script src="js/prefixfree.min.js"> </script>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, maximum-scale=1"/>
        <link href="css/simplePagination.css" type="text/css" rel="stylesheet"/>
	  <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
	  <script src="//code.jquery.com/jquery-1.10.2.js"></script>
	  <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
	  <link rel="stylesheet" href="/resources/demos/style.css">
	  <script>
	  //$(function() {
	  $(document).ready(function() {
	    //$( "#datepicker" ).datepicker();
	    $("#start_datepicker").datepicker();
	    $("#end_datepicker").datepicker();
	    //$("#start_datepicker").datepicker({dateformat: 'yy-mm-dd'});
	    //$("#end_datepicker").datepicker({dateformat: 'yy-mm-dd'});
	    //dateformat: 'yyyy-mm-dd'
	  });
	  </script>
        <script>
            if(typeof window.history.pushState == 'function') {
                window.history.pushState({}, "Hide", '<?php echo $_SERVER['PHP_SELF'];?>');
            }
        </script>
	<script>
	$(function() {
	    var pressed = false;
	    var start = undefined;
	    var startX, startWidth;
    
	    $("table th").mousedown(function(e) {
	        start = $(this);
	        pressed = true;
	        startX = e.pageX;
	        startWidth = $(this).width();
	        $(start).addClass("resizing");
	    });
    
	    $(document).mousemove(function(e) {
	        if(pressed) {
	            $(start).width(startWidth+(e.pageX-startX));
	        }
	    });
    
	    $(document).mouseup(function() {
	        if(pressed) {
	            $(start).removeClass("resizing");
	            pressed = false;
        	}
	    });
	});
        </script>
    <script>
        next_page='test_history.php'
    function  DelId(element) {
                r = element.parentNode.parentNode.rowIndex;
                l = element.parentNode.cellIndex;
                var myTable = document.getElementById('content').tBodies[0];
                //get first cell of this row in the table
                taskid=myTable.rows[r].cells[0].innerHTML;
                form = document.createElement('form');
                form.setAttribute('method', 'POST');
                form.setAttribute('action', next_page);

                //set operation: del/...
                opt = 'del';
                myvar = document.createElement('input');
                myvar.setAttribute('name', opt);
                myvar.setAttribute('type', 'text');
                myvar.setAttribute('value', opt);
                form.appendChild(myvar);
                //test taskid
                myvar1 = document.createElement('input');
                myvar1.setAttribute('name', 'taskid');
                myvar1.setAttribute('type', 'text');
                myvar1.setAttribute('value', taskid);
                form.appendChild(myvar1);

                if (confirm("Only Admin can Delete Results!"))
                {
                document.body.appendChild(form);
                form.submit();
                }
    }
    function  ResultId(element) {
                next_page='results.php'
                //next_page='test_history1.php'
                r = element.parentNode.parentNode.rowIndex;
                l = element.parentNode.cellIndex;
                var myTable = document.getElementById('content').tBodies[0];

                //get first cell of this row in the table
                taskid=myTable.rows[r].cells[0].innerHTML;

                form = document.createElement('form');
                form.setAttribute('method', 'POST');
                form.setAttribute('action', next_page);

                //set operation: result/...
                opt = 'result';
                myvar = document.createElement('input');
                myvar.setAttribute('name', opt);
                myvar.setAttribute('type', 'text');
                myvar.setAttribute('value', opt);
                form.appendChild(myvar);
                //test taskid
                myvar1 = document.createElement('input');
                myvar1.setAttribute('name', 'taskid');
                myvar1.setAttribute('type', 'text');
                myvar1.setAttribute('value', taskid);
                form.appendChild(myvar1);

                document.body.appendChild(form);
                form.submit();
    }
    function  ReTestId(element) {
                //next_page='taskqueue.php'
                r = element.parentNode.parentNode.rowIndex;
                l = element.parentNode.cellIndex;
                var myTable = document.getElementById('content').tBodies[0];

                //get first cell of this row in the table
                taskid=myTable.rows[r].cells[0].innerHTML;

                form = document.createElement('form');
                form.setAttribute('method', 'POST');
                form.setAttribute('action', next_page);

                //set operation: retest/...
                opt = 'retest';
                myvar = document.createElement('input');
                myvar.setAttribute('name', opt);
                myvar.setAttribute('type', 'text');
                myvar.setAttribute('value', opt);
                form.appendChild(myvar);
                //test taskid
                myvar1 = document.createElement('input');
                myvar1.setAttribute('name', 'taskid');
                myvar1.setAttribute('type', 'text');
                myvar1.setAttribute('value', taskid);
                form.appendChild(myvar1);

                if (confirm("Want to Retest?"))
                 {
                        document.body.appendChild(form);
                        form.submit();
                 }
    }
    function  TestFailOnlyId(element) {
                next_page='test_history.php'
                r = element.parentNode.parentNode.rowIndex;
                l = element.parentNode.cellIndex;
                var myTable = document.getElementById('content').tBodies[0];

                //get first cell of this row in the table
                taskid=myTable.rows[r].cells[0].innerHTML;
                wanlist = myTable.rows[r].cells[5].innerHTML;
                passfail = myTable.rows[r].cells[7].innerHTML;

                form = document.createElement('form');
                form.setAttribute('method', 'POST');
                form.setAttribute('action', next_page);

                //set operation: del/...
                opt = 'testfailonly';
                myvar = document.createElement('input');
                myvar.setAttribute('name', opt);
                myvar.setAttribute('type', 'text');
                myvar.setAttribute('value', opt);
                form.appendChild(myvar);
                //test taskid
                myvar1 = document.createElement('input');
                myvar1.setAttribute('name', 'taskid');
                myvar1.setAttribute('type', 'text');
                myvar1.setAttribute('value', taskid);
                form.appendChild(myvar1);
                //test wanlist
                myvar2 = document.createElement('input');
                myvar2.setAttribute('name', 'wanlist');
                myvar2.setAttribute('type', 'text');
                myvar2.setAttribute('value', wanlist);
                form.appendChild(myvar2);
                //test passfail
                myvar3 = document.createElement('input');
                myvar3.setAttribute('name', 'passfail');
                myvar3.setAttribute('type', 'text');
                myvar3.setAttribute('value', passfail);
                form.appendChild(myvar3);
                myvar4 = passfail.search(/green/i);
                //alert(myvar4);
                if (myvar4 != -1){
                   alert("No Failure,Click Retest Button")
                 }
                 else{
                  if (confirm("Confirm the Failyonly test !"))
                        document.body.appendChild(form);
                        form.submit();
                 }
    }
   </script>
  </head>
  <body>

    <?php include "menu.html"; ?>
    <script src="js/index.js"> </script>
        <?php
           //date_default_timezone_set('Asia/Jakarta');
           $date = date('m/d/Y h:i:s a', time());
           session_start();
           $_SESSION['url'] = $_SERVER['REQUEST_URI'];

           if($_POST["del"] && $_POST["taskid"])
            {
             if(!$_SESSION['login']==session_id())
               {
                header("Location: login.php");
              }
              else
                {
                $fileName = "$log_dir/historydeletedbyuser.txt";
                ob_start();
                echo "User:".$_SESSION['user']. " |";
                echo "SessionId: ". session_id(). " |";
                echo "IP: ".$_SESSION['ip']. " |";
                echo "time: ".$date." |";
                echo $taskid ." |";
                echo "del ". $_POST['taskid']. "|";
                $obStr = ob_get_contents();
                ob_end_clean();
                file_put_contents($fileName, $obStr." \n", FILE_APPEND);

                //Call Python script to delete task from database
                if($_SESSION['user'] == 'admin')
                {
                $taskid = $_POST['taskid'];
                $output = shell_exec("python pyss/delhistory.py $taskid");
                echo $output;
                }
                else
                {
                echo '<script language="javascript">';
                echo 'alert("Not Login as admin!")';
                echo '</script>';
                header("Location:test_history.php");
                }
              }
           }
           elseif( $_POST["result"] && $_POST["taskid"] )
            {
                $taskid = $_POST["taskid"];
                $command = escapeshellcmd("python pyss/test_history1.py $taskid");
                $output = shell_exec($command);
                print_r($output);
                header("Location:test_history1.php");

           }
           elseif( $_POST["retest"] && $_POST["taskid"] )
            {
                $taskid = $_POST["taskid"];
                $stime = date("Y-m-d H:i:s");
                $command = escapeshellcmd("python pyss/retest.py '$taskid' '$stime'");
                $output = shell_exec($command);
                //print_r($output);
                header("Location:taskqueue.php");
           }
          elseif( $_GET["retest"] && $_GET["taskid"] )
            {
                $taskid = $_GET["taskid"];
                $stime = date("YmdHis");
                $command = escapeshellcmd("python pyss/retest.py '$taskid' '$stime'");
                $output = shell_exec($command);
                //print_r($output);
                header("Location:taskqueue.php");
           }
           elseif( $_POST["testfailonly"] && $_POST["taskid"] )
            {
		$wanlist = $_POST["wanlist"];
		$passfail = $_POST["passfail"];
                $taskid = $_POST["taskid"];
                $stime = date("Y-m-d H:i:s");
                $command = escapeshellcmd("python pyss/failonly.py '$taskid' '$stime'");
                $output = shell_exec($command);
                header("Location:taskqueue.php");
                }
                //print_r($passfail);
             //echo "testfailonly ". $_POST['taskid']. "<br />";
           //}
                /*$command = escapeshellcmd('pyss/test_history.py');
                $output = shell_exec($command);
                print_r($output);*/

	//********* Connect To DataBase ***************
	/*function getDB() {
        	$dbConnection = new PDO("sqlite:../db/bsptestserver.db");
	        $dbConnection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	        return $dbConnection;
	}*/
	include "config.php";

	/*//************** <Search_Section> ****************
        if($_POST["action"] == "Search")
        {
                if (!empty($_POST["fromdate"])){$fromdate = date("Y-m-d", strtotime($_POST["fromdate"]));}
                else{$fromdate = 'fromdate';}
                if (!empty($_POST["todate"])){$todate = date("Y-m-d", strtotime($_POST["todate"]));}
                else{$todate = 'todate';}
                if (!empty($_POST["user"])){$user = $_POST["user"];}
                else{$user = 'user';}
                if (!empty($_POST["model"])){$model = $_POST["model"];}
                else{$model = 'model';}
                if (!empty($_POST["meta"])){$meta = $_POST["meta"];}
                else{$meta = 'meta';}
                if (!empty($_POST["greaterthan"])){$greaterthan = $_POST["greaterthan"];}
                else{$greaterthan = 'greaterthan';}
                if (!empty($_POST["lessthan"])){$lessthan = $_POST["lessthan"];}
                else{$lessthan = 'lessthan';}
                if (!empty($_POST["wan"])){$wan = $_POST["wan"];}
                else{$wan = 'wan';}
                if (!empty($_POST["setup"])){$setup = $_POST["setup"];}
                else{$setup = 'setup';}

                //Calling python script with parameters to search from db
                $command = escapeshellcmd("python pyss/search.py '$fromdate' '$todate' '$user' '$model' '$meta' '$greaterthan' '$lessthan' '$wan' '$setup'");
                $output = shell_exec($command);
                print_r($output);
                exit;
        }

	// *************** </Search_Section> ****************

	else{*/
	try {
        	$DB=getDB();
	        // page is the current page, if there's nothing set, default is page 1
	        $page = isset($_GET['page']) ? $_GET['page'] : 1;

	        // set records or rows of data per page
	        $recordsPerPage = 16;

        	// calculate for the query LIMIT clause
	        $fromRecordNum = ($recordsPerPage * $page) - $recordsPerPage;

      // Define variable for operation buttons
	$op = "<input type=button value=Result onclick=\"ResultId(this)\"> <input type=button value=Del onclick=\"DelId(this)\"> <input type=button value=Retest onclick=\"ReTestId(this)\"> <input type=button value=TestFailOnly onclick=\"TestFailOnlyId(this)\">";

	//Use GET Method for Search Option.
	if (!empty($_GET["fromdate"])) {
		if (strpos($_GET["fromdate"], '%2F') !== false) {
			date("Y-m-d H:i:s", strtotime(str_replace('%2F', '-', $_GET["fromdate"])));
		} else {
			$fromdate = date("Y-m-d H:i:s", strtotime($_GET["fromdate"]));
		}
	} else {
		$fromdate = '2000-01-01 00:00:00';
	}
	if (!empty($_GET["todate"])) {
		$todate = date("Y-m-d H:i:s", strtotime($_GET["todate"]));
		if ($fromdate == $todate) {
			$todate = date("Y-m-d H:i:s", strtotime($fromdate . ' +1 day'));
		} else {
			$todate = date("Y-m-d H:i:s", strtotime($_GET["todate"]));
		}
	} else {
		$dt = new DateTime();
		$todate = $dt->format("Y-m-d H:i:s");
	}
	if (!empty($_GET["user"])) {
		$user = $_GET["user"];
	} else {
		$user = '%';
	}
	if (!empty($_GET["model"])) {
		$model = $_GET["model"];
	} else {
		$model = '%';
	}
	if (!empty($_GET["meta"])) {
		$meta = $_GET["meta"];
	} else {
		$meta = '%';
	}
	if (!empty($_GET["wan"])) {
		$wan = $_GET["wan"];
	} else {
		$wan = '%';
	}
	if (!empty($_GET["setup"])) {
		$setup = $_GET["setup"];
	} else {
		$setup = '%';
	}
	if (!empty($_GET["greaterthan"]) && empty($_GET["lessthan"])) {
		$greaterthan = $_GET["greaterthan"];
		$query = "SELECT * FROM test_history WHERE submit_time BETWEEN '$fromdate' AND '$todate' AND user LIKE '%" . $user . "%' AND model LIKE '%" . $model ."%' AND wan LIKE '%" . $wan . "%' AND duration >= '$greaterthan' AND setup_id LIKE '%" . $setup . "%' AND meta LIKE '%" . $meta . "%' ORDER BY task DESC LIMIT {$fromRecordNum}, {$recordsPerPage}";
		$countquery = "SELECT COUNT(*) as total_rows FROM test_history WHERE submit_time BETWEEN '$fromdate' AND '$todate' AND user LIKE '%" . $user . "%' AND model LIKE '%" . $model ."%' AND wan LIKE '%" . $wan . "%' AND duration >= '$greaterthan' AND setup_id LIKE '%" . $setup . "%' AND meta LIKE '%" . $meta . "%'";
	} elseif (!empty($_GET["lessthan"]) && empty($_GET["greaterthan"])) {
		$lessthan = $_GET["lessthan"];
		$query = "SELECT * FROM test_history WHERE submit_time BETWEEN '$fromdate' AND '$todate' AND user LIKE '%" . $user . "%' AND model LIKE '%" . $model ."%' AND wan LIKE '%" . $wan . "%' AND duration <= '$lessthan' AND setup_id LIKE '%" . $setup . "%' AND meta LIKE '%" . $meta . "%' ORDER BY task DESC LIMIT {$fromRecordNum}, {$recordsPerPage}";
		$countquery = "SELECT COUNT(*) as total_rows FROM test_history WHERE submit_time BETWEEN '$fromdate' AND '$todate' AND user LIKE '%" . $user . "%' AND model LIKE '%" . $model ."%' AND wan LIKE '%" . $wan . "%' AND duration <= '$lessthan' AND setup_id LIKE '%" . $setup . "%' AND meta LIKE '%" . $meta . "%'";
	} elseif (!empty($_GET["lessthan"]) && !empty($_GET["greaterthan"])) {
		$lessthan = $_GET["lessthan"];
		$greaterthan = $_GET["greaterthan"];
		$query = "SELECT * FROM test_history WHERE submit_time BETWEEN '$fromdate' AND '$todate' AND user LIKE '%" . $user . "%' AND model LIKE '%" . $model ."%' AND wan LIKE '%" . $wan . "%' AND (duration <= '$lessthan' OR duration >= '$greaterthan') AND setup_id LIKE '%" . $setup . "%' AND meta LIKE '%" . $meta . "%' ORDER BY task DESC LIMIT {$fromRecordNum}, {$recordsPerPage}";
		$countquery = "SELECT COUNT(*) as total_rows FROM test_history WHERE submit_time BETWEEN '$fromdate' AND '$todate' AND user LIKE '%" . $user . "%' AND model LIKE '%" . $model ."%' AND wan LIKE '%" . $wan . "%' AND (duration >= '$greaterthan' OR duration <= '$lessthan') AND setup_id LIKE '%" . $setup . "%' AND meta LIKE '%" . $meta . "%'";
	} else {
		$query = "SELECT * FROM test_history WHERE submit_time BETWEEN '$fromdate' AND '$todate' AND user LIKE '%" . $user . "%' AND model LIKE '%" . $model ."%' AND wan LIKE '%" . $wan . "%' AND setup_id LIKE '%" . $setup . "%' AND meta LIKE '%" . $meta . "%' ORDER BY task DESC LIMIT {$fromRecordNum}, {$recordsPerPage}";
		$countquery = "SELECT COUNT(*) as total_rows FROM test_history WHERE submit_time BETWEEN '$fromdate' AND '$todate' AND user LIKE '%" . $user . "%' AND model LIKE '%" . $model ."%' AND wan LIKE '%" . $wan . "%' AND setup_id LIKE '%" . $setup . "%' AND meta LIKE '%" . $meta . "%'";
	}



//       $query = "SELECT * FROM test_history WHERE submit_time BETWEEN '$fromdate' AND '$todate' AND user LIKE '%" . $user . "%' AND model LIKE '%" . $model ."%' AND wan LIKE '%" . $wan . "%' AND (duration <= '$lessthan' OR duration >= '$greaterthan') AND setup_id LIKE '%" . $setup . "%' AND meta LIKE '%" . $meta . "%' ORDER BY task DESC LIMIT {$fromRecordNum}, {$recordsPerPage}";

                $stmt = $DB->prepare( $query );
                $stmt->execute();

                $result = $stmt->fetchAll();

                if(count($result) > 0) {
            // *************** <PAGING_SECTION> ***************
            echo "<div id='paging'>";

                // ***** for 'first' and 'previous' pages
                if($page>1){
                    // ********** show the first page
                    $QS = http_build_query(array_merge($_GET, array("page"=>1)));
                    echo "<a href='" . htmlspecialchars("$_SERVER[PHP_SELF]?$QS") . "'title='Go to the first page.' class='customBtn'>";
                    //echo "<a href='" . $_SERVER['PHP_SELF'] ."'title='Go to the first page.' class='customBtn'>";
                        echo "<span style='margin:0 .5em;'> first </span>";
                    echo "</a>";

                    // ********** show the previous page
                    $prev_page = $page - 1;
                        $QS = http_build_query(array_merge($_GET, array("page"=>$prev_page)));
                        echo "<a href='" . htmlspecialchars("$_SERVER[PHP_SELF]?$QS") . "'title='Previous page is {$prev_page}' class='customBtn'>";
                    //echo "<a href='" . $_SERVER['PHP_SELF']
                    //        . "?page={$prev_page}" . $_SERVER['QUERY_STRING'] . "'title='Previous page is {$prev_page}' class='customBtn'>";
                        echo "<span style='margin:0 .5em;'> Previous </span>";
                    echo "</a>";

                }

                // ********** show the number paging
                // find out total pages
//     $countquery = "SELECT COUNT(*) as total_rows FROM test_history WHERE submit_time BETWEEN '$fromdate' AND '$todate' AND user LIKE '%" . $user . "%' AND model LIKE '%" . $model ."%' AND meta LIKE '%" . $meta . "%'";
//	$countquery = "SELECT COUNT(*) as total_rows FROM test_history WHERE submit_time BETWEEN '$fromdate' AND '$todate' AND user LIKE '%" . $user . "%' AND model LIKE '%" . $model ."%' AND wan LIKE '%" . $wan . "%' AND (duration >= '$greaterthan' OR duration <= '$lessthan') AND setup_id LIKE '%" . $setup . "%' AND meta LIKE '%" . $meta . "%'";

                $countstmt = $DB->prepare( $countquery );
                $countstmt->execute();

                $row = $countstmt->fetch(PDO::FETCH_ASSOC);
                $total_rows = $row['total_rows'];
                //echo "Total records:" .  $total_rows;
                $total_pages = ceil($total_rows / $recordsPerPage);

                // range of num links to show
                $range = 10;

                // display links to 'range of pages' around 'current page'
                $initial_num = $page - $range;
                $condition_limit_num = ($page + $range)  + 1;

                for ($x=$initial_num; $x<$condition_limit_num; $x++) {

                    // be sure '$x is greater than 0' AND 'less than or equal to the $total_pages'
                    if (($x > 0) && ($x <= $total_pages)) {

                        // current page
                        if ($x == $page) {
                            echo "<span class='customBtn' style='background:yellow;'>$x</span>";
                        }

                        // not current page
                        else {
                                $QS = http_build_query(array_merge($_GET, array("page"=>$x)));
                                echo "<a href='" . htmlspecialchars("$_SERVER[PHP_SELF]?$QS") . "'> $x </a>";
                        }
                    }
                }

                // ***** for 'next' and 'last' pages
                if($page<$total_pages){
                    // ********** show the next page
                    $next_page = $page + 1;
                    $QS = http_build_query(array_merge($_GET, array("page"=>$next_page)));
                    echo "<a href='" . htmlspecialchars("$_SERVER[PHP_SELF]?$QS"). "'title='Next page is {$next_page}' class='customBtn'>";
                    //echo "<a href='" . $_SERVER['PHP_SELF'] . "?page={$next_page}" . $_SERVER['QUERY_STRING'] . "'title='Next page is {$next_page}' class='customBtn'>";
                        echo "<span style='margin:0 .5em;'> Next </span>";
                    echo "</a>";

                    // ********** show the last page
                    //echo "<a href='" . $_SERVER['PHP_SELF'] . "?page={$total_pages}" . $_SERVER['QUERY_STRING'] . "'title='Last page is {$total_pages}' class='customBtn'>";
                    $QS = http_build_query(array_merge($_GET, array("page"=>$total_pages)));
                    echo "<a href='" . htmlspecialchars("$_SERVER[PHP_SELF]?$QS"). "'title='Last page is {$total_pages}' class='customBtn'>";
                        echo "<span style='margin:0 .5em;'> Last </span>";
                    echo "</a>";
                }
            echo "</div>";

            // ***** allow user to enter page number
            echo "<form action='" . $_SERVER['PHP_SELF'] . "' method='GET'>";
                echo "Total Results Found:<font color=green face='verdana' size='4'><b>  $total_rows</b></font>" . "&nbsp;&nbsp;&nbsp;&nbsp;";
                echo "Total No of Pages: <font color=green face='verdana' size='4'><b>{$total_pages}</b></font>" . "&nbsp;&nbsp;&nbsp;&nbsp;";
                echo "Go To Page: ";
                echo "<input type='text' name='page' size='1' />";
                echo "<input type='submit' value='Go' class='customBtn' />";
            echo "</form>";
        // *************** </PAGING_SECTION> ***************
        } else {
                 echo "Sorry, no results found";
        }

	//start table
	echo "<table id=\"content\" border=1>";
	//creating our table heading
	echo '<tr><form action="test_history.php" method="GET"><th>Task<p>Id</th> <th>Submit Time<p>From<input type="text" data-date-format="yy-mm-dd" id="start_datepicker" placeholder="Start Date" name="fromdate" style="width: 70px;"/><p>To<input type="text" data-date-format="yy-mm-dd" id="end_datepicker" placeholder="End Date" name="todate" style="width: 70px;"/></th> <th>Dispatch<p>Time</th> <th>User<p><input type="text" placeholder="Search By User" name="user" style="width: 100px;"/></th> <th>Model<p><input type="text" placeholder="Search By Model" name="model"/></th> <th>WAN Mode<p><input type="text" style="width: 40px;" placeholder="WAN" name="wan"/></th> <th>Test Duration<p>More Than<input type="text" placeholder="H:MM:SS" name="greaterthan" style="width: 60px;"/><p>Less Than<input type="text" name="lessthan" placeholder="H:MM:SS" style="width: 60px;"/></th> <th>Result<p>Pass/Fail</th> <th>Setup Id<p><input type="text" placeholder="Setup" style="width: 40px;" name="setup"/></th> <th>Meta Info<p><input type="text" placeholder="Search By Meta Info" name="meta"/></th> <th>Test Group</th> <th>Operation<p><input type="submit" value="Search" name="action" style="height:30px;width:90px"/></th></form></tr>';
        foreach ($result as $row) {
                extract($row);
            //creating new table row per record
            echo "<tr>";
                echo "<td>{$task}</td>";
                echo "<td>{$submit_time}</td>";
                echo "<td>{$dispatch_time}</td>";
                echo "<td>{$user}</td>";
                echo "<td>{$model}</td>";
                echo "<td>{$wan}</td>";
                echo "<td>{$duration}</td>";
                echo "<td>{$status}</td>";
                echo "<td>{$setup_id}</td>";
                echo "<td>{$meta}</td>";
                echo "<td>{$tc_grp}</td>";
                echo "<td>{$op}</td>";
            echo "</tr>";
                }
            echo "</table>";//end table        
	// close the database connection
	$DB = NULL;        
	}        
	catch(PDOException $e){
	    echo 'Exception : '.$e->getMessage();
	}
    ?>
  </body>
</html>
