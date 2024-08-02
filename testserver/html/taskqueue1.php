<?php
        session_start();
        $taskid = $_POST['taskid'];
        $fileName = "test_info.php";
        ob_start();
        $command = escapeshellcmd("python pyss/taskqueue1.py $taskid");
        $output = shell_exec($command);
        print_r($output);
        $obStr = ob_get_contents();
        ob_end_clean();
        file_put_contents($fileName, $obStr);
?>
<!DOCTYPE html>
<html >
  <head>
    <link rel="stylesheet" type="text/css" href="css\style.css">
    <script src="js/prefixfree.min.js"> </script>
    <script src="js/index.js"> </script>
  <!-- refresh every 5 seconds -->
  <meta http-equiv="refresh" content="6000">
<frameset cols="50%,*" frameborder="no" framespacing=0>
  <frameset rows="100%,*" frameborder="no" framespacing=0>
     <frame name="TestInfo" src="test_info.php" marginheight=2 marginwidth=5 scrolling=auto>
   </frameset>
<?php
	$command = escapeshellcmd("python pyss/getsetupip.py $taskid");
        $ipaddr = shell_exec($command);
        //print_r($ipaddr);
	echo "<frameset rows=\"15%,25%,60%,*\" frameborder=\"no\" framespacing=0>"."<br>";
	echo "<frame name=\"TaskFrame\" src=\"http://".$ipaddr."/auto_live_status.htm\" marginheight=2  marginwidth=5 scrolling=auto>"."<br>";
	echo "<frame name=\"TestCaseFrame\" src=\"http://".$ipaddr."/auto_live_testcase.htm\" marginheight=2  marginwidth=5 scrolling=auto>"."<br>";
	echo "<frame name=\"ConsoleFrame\" src=\"http://".$ipaddr."/cgi-bin/auto_live_log.pl\" marginheight=2 marginwidth=5 scrolling=auto>"."<br>";
	echo "<frame name=\"TestSetupStatus\" src=\"result_eth.htm\" marginheight=2 marginwidth=5 scrolling=auto>"."<br>";
	echo "</frameset>";
?>
</frameset>
</head>
<body>
<?php include "menu.html"; ?>
</body>
</html>
