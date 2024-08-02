<?php
	session_start();
	include "config.php";
	$taskid = $_POST['taskid'];
 	if ("" == $taskid){
		$taskid = $_GET['taskid'];}
	$command1 = escapeshellcmd("python pyss/rr.py $taskid");
        $output = shell_exec($command1);

        $fileName = "test_history1.php";
        ob_start();
        $command = escapeshellcmd("python pyss/test_history1.py $taskid");
        $output = shell_exec($command);
        print_r($output);		
        $obStr = ob_get_contents();
        ob_end_clean();
        file_put_contents($fileName, $obStr);
        ob_end_flush();
        $fileName1 = "result2.php";
        ob_start();
        $command1 = escapeshellcmd("python pyss/result2.py $taskid");
        $output1 = shell_exec($command1);
        print_r($output1);
        $obStr1 = ob_get_contents();
        ob_end_clean();
        file_put_contents($fileName1, $obStr1);
        ob_end_flush();
?>
<!-- Doctype html -->
<html>
<head>
<link rel="stylesheet" type="text/css" href="css\style.css">
<script src="js/prefixfree.min.js"> </script>
<title>Results</title>
<!-- refresh every 5 seconds -->
<meta http-equiv="refresh" content="6000">
<frameset cols="50%,*" frameborder="yes" framespacing=1>
  <frameset rows="100%,*" frameborder="yes" framespacing=1>
     <frame name="TestHistory" src="test_history1.php" marginheight=2 marginwidth=5 scrolling=auto>
   </frameset>
  <frameset rows="50%,50%,*" frameborder="yes" framespacing=1>
     <frame name="TestCaseFrame" src="results/<?php echo $taskid.'/results.htm';?>" marginheight=2  marginwidth=5 scrolling=auto onerror="fileError()">
     <frame name="ConsoleFrame" src="result2.php" marginheight=2 marginwidth=5 scrolling=auto>
     <frame name="TestSetupStatus" src="results/result_eth.htm" marginheight=2 marginwidth=5 scrolling=auto>
  </frameset>
</frameset>
</head>
<body>
<?php include "menu.html"; ?>
<script src="js/index.js"> </script>
</body>
</html>
