<?php
	session_start();
	$taskid = $_POST['$task_id'];
	echo $taskid;
?>
<!DOCTYPE html>
<html >
  <head>
    <link rel="stylesheet" type="text/css" href="css\style.css">
    <script src="js/prefixfree.min.js"> </script>
  <!-- refresh every 60 seconds -->
  <meta http-equiv="refresh" content="60">
  </head>
  <body>
    <nav class="animenu">
  <ul class="animenu__nav">
    <li>
      <a href="">Test Results</a>
    </li>
   </ul>
</nav>
    <script src="js/index.js"> </script>
	<?php
		$command = escapeshellcmd('pyss/results.py');
		$output = shell_exec($command);
		print_r($output);
/*    <table id="tasklist" border=1>
    <tr>
       <th>TestCase_Name</th> <th>Result</th> <th>Duration</th>
    </tr>

       <tr><td>TestCase1</td> <td>PASS</td> <td>66</td></tr>
       <tr><td>TestCase2</td> <td>PASS</td> <td>72</td></tr>
       <tr><td>TestCase3</td> <td>FAIL</td> <td>132</td></tr>
*/
	?>
  </body>
</html>
