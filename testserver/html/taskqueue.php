<?php
	session_start();
	if (($_SERVER['REQUEST_METHOD'] === 'POST') && ($_POST["del"])) {
		if(!$_SESSION['login']==session_id())  {
			echo "2Please log in to delete task"."<br>";
			echo "<a href='login.php'>Login</a>" . "<br>";
			header("location: login.php");
			exit("");
		}
	}
?>

<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="css\style.css">
<script src="js/prefixfree.min.js"> </script>
<script>
		next_page='taskqueue.php'
		function DelId(element)
		{
		r = element.parentNode.parentNode.rowIndex;
		l = element.parentNode.cellIndex;
		var myTable = document.getElementById('tasklist').tBodies[0];
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

		if (confirm("Please Login to Delete."))
		{
			document.body.appendChild(form);
			form.submit();
		}
	}
</script>
<script>
		function stop(element)
		{
		next_page='taskqueue.php'
		r = element.parentNode.parentNode.rowIndex;
		l = element.parentNode.cellIndex;
		var myTable = document.getElementById('tasklist').tBodies[0];
		//get first cell of this row in the table
		taskid=myTable.rows[r].cells[0].innerHTML;

		form = document.createElement('form');
		form.setAttribute('method', 'POST');
		form.setAttribute('action', next_page);

		//set operation: stop/...
		opt = 'stop';
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

		if (confirm("Not Supported!!"))
		{
		document.body.appendChild(form);
		form.submit();
		}
		}
</script>
<script>
		function Info(element)
		{
		next_page='taskqueue1.php'
		r = element.parentNode.parentNode.rowIndex;
		l = element.parentNode.cellIndex;
		var myTable = document.getElementById('tasklist').tBodies[0];

		//get first cell of this row in the table
		taskid=myTable.rows[r].cells[0].innerHTML;

		form = document.createElement('form');
		form.setAttribute('method', 'POST');
		form.setAttribute('action', next_page);

		//Write Code to display detail Info abt task
		opt = 'Info';
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
</script>
</head>
<body>
<?php include "menu.html"; ?>
<?php include "config.php"; ?>
<script src="js/index.js"> </script>

<?php
	//date_default_timezone_set('Asia/Jakarta');
	$date = date('m/d/Y h:i:s a', time());
	session_start();
	$_SESSION['url'] = $_SERVER['REQUEST_URI'];
	if( $_POST["del"] && $_POST["taskid"] )
	{
		if(!$_SESSION['login']==session_id())
		{
		echo "2Please log in to delete task"."<br>";
		echo $_SESSION['login']."<br>";
		echo "SessionId: ". session_id(). "<br />";
		echo "_SESSION: ".$_SESSION['login']. "<br />";
		header("location:login.php");
		}
		else
		{
		$fileName = "$log_dir/taskdeletedbyuser.txt";
		ob_start();
		echo "User:".$_SESSION['user']. " |";
		echo "SessionId: ". session_id(). " |";
		echo "IP: ".$_SESSION['ip']." |";
		echo "time: ".$date." |";
		echo $taskid." |";
		echo "del ". $_POST['taskid'];
		$obStr = ob_get_contents();
		ob_end_clean();
		file_put_contents($fileName, $obStr." \n", FILE_APPEND);

		//Call Python script to delete task from database
		$taskid = $_POST['taskid'];
		$user = $_SESSION['user'];
		$output = shell_exec("python pyss/delete1.py $taskid $user");
		echo $output;
		}
	}
	elseif( $_POST["Info"] && $_POST["taskid"] )
	{
		echo $taskid;
		echo "Info ". $_POST['taskid']. "<br />";
		$command = escapeshellcmd("python pyss/queue.py $taskid");
		$output = shell_exec($command);
		print_r($output);
	}
		/*$command = escapeshellcmd('pyss/queue.py');
		$output = shell_exec($command);
		print_r($output);*/


	try {
		$DB=getDB();
		// find out total pages
		$countquery = "SELECT COUNT(*) as total_rows FROM queue";
		$stmt = $DB->prepare( $countquery );
		$stmt->execute();

		$row = $stmt->fetch(PDO::FETCH_ASSOC);
		$total_rows = $row['total_rows'];

		if ($total_rows < 50){
			$command = escapeshellcmd('pyss/queue.py');
			$output = shell_exec($command);
			print_r($output);
		}else{

		// page is the current page, if there's nothing set, default is page 1
		$page = isset($_GET['page']) ? $_GET['page'] : 1;

		// set records or rows of data per page
		$recordsPerPage = 50;

		// calculate for the query LIMIT clause
		$fromRecordNum = ($recordsPerPage * $page) - $recordsPerPage;

		// select all data
		$query = "SELECT task, submit_time, user, model, wan, ttype, status, meta, tc_grp FROM queue ORDER BY task DESC LIMIT {$fromRecordNum}, {$recordsPerPage}";

		// Define variable for operation buttons
		$op = "<input type=button value=Del onclick=\"DelId(this)\"> <input type=button value=Stop onclick=\"stop(this)\"> <input type=button value=Info onclick=\"Info(this)\">";

		$stmt = $DB->prepare( $query );
		$stmt->execute();

		$result = $stmt->fetchAll();
		if(count($result) > 0) {
			// *************** <PAGING_SECTION> ***************
			echo "<div id='paging'>";

			// ***** for 'first' and 'previous' pages
			if($page>1){
				// ********** show the first page
				echo "<a href='" . $_SERVER['PHP_SELF'] . "' title='Go to the first page.' class='customBtn'>";
				echo "<span style='margin:0 .5em;'> << </span>";
				echo "</a>";

				// ********** show the previous page
				$prev_page = $page - 1;
				echo "<a href='" . $_SERVER['PHP_SELF']
				. "?page={$prev_page}' title='Previous page is {$prev_page}.' class='customBtn'>";
				echo "<span style='margin:0 .5em;'> < </span>";
				echo "</a>";

			}

			// ********** show the number paging

			$total_pages = ceil($total_rows / $recordsPerPage);

			// range of num links to show
			$range = 5;

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
					echo " <a href='{$_SERVER['PHP_SELF']}?page=$x' class='customBtn'>$x</a> ";
				}
			}
			}

			// ***** for 'next' and 'last' pages
			if($page<$total_pages){
				// ********** show the next page
				$next_page = $page + 1;
				echo "<a href='" . $_SERVER['PHP_SELF'] . "?page={$next_page}' title='Next page is {$next_page}.' class='customBtn'>";
				echo "<span style='margin:0 .5em;'> > </span>";
				echo "</a>";

				// ********** show the last page
				echo "<a href='" . $_SERVER['PHP_SELF'] . "?page={$total_pages}' title='Last page is {$total_pages}.' class='customBtn'>";
				echo "<span style='margin:0 .5em;'> >> </span>";
				echo "</a>";
			}
			echo "</div>";

			// ***** allow user to enter page number
			/* echo "<form action='" . $_SERVER['PHP_SELF'] . "' method='GET'>";
			echo "Total no of Pages: <font color=green face='verdana' size='4'><b>[{$total_pages}]</b></font>" . "&nbsp;&nbsp;&nbsp;&nbsp;";
			echo "Go to page: ";
			echo "<input type='text' name='page' size='1' />";
			echo "<input type='submit' value='Go' class='customBtn' />";
			echo "</form>";*/

			// *************** </PAGING_SECTION> ***************
			//start table
			echo "<table id=\"tasklist\" border=1>";
			//creating our table heading
			echo '<tr><th>TaskId</th> <th>Submit<p>Time</th> <th>User</th> <th>Model</th> <th>WAN<p>Mode</th> <th>Test<p>Type</th> <th>Status</th> <th>Meta<p>Info</th> <th>Test Group</th> <th>Operation</th></tr>';
			foreach ($result as $row) {
				extract($row);
				//creating new table row per record
				echo "<tr>";
				echo "<td>{$task}</td>";
				echo "<td>{$submit_time}</td>";
				echo "<td>{$user}</td>";
				echo "<td>{$model}</td>";
				echo "<td>{$wan}</td>";
				echo "<td>{$ttype}</td>";
				echo "<td>{$status}</td>";
				echo "<td>{$meta}</td>";
				echo "<td>{$tc_grp}</td>";
				echo "<td>{$op}</td>";
				echo "</tr>";
			}
			echo "</table>";//end table
		} else {
			echo "Sorry, no results found";
		}
			// close the database connection
			$DB = NULL;
		}
	}catch(PDOException $e){
		echo 'Exception : '.$e->getMessage();
	}
?>
</body>
</html>
