<?php
$log_dir = "/testserver/db/log/";
$log_file = "automation.log";
$logs = "$log_dir/$log_file";
$log_size = number_format(filesize($logs) / 1048576, 2);

	function tailFile($filepath, $lines = 1) {
		return trim(implode("", array_slice(file($filepath), -$lines)));
	}
        if(isset($_POST["serverlog"]))
                {
                $type = filetype($logs);
                header("Content-type: $type");
                header("Content-Disposition: attachment;filename=$logs");
                header("Content-Transfer-Encoding: binary");
                header('Pragma: no-cache');
                header('Expires: 0');
                set_time_limit(0);
                readfile($logs);
		exit();
        }
?>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="css\style.css">
<script src="js/prefixfree.min.js"> </script>
  <!-- refresh every 30 seconds -->
  <meta http-equiv="refresh" content="30">
</head>
<body onLoad="scroll_down()">
<script>
	function scroll_down()
	{
		window.scroll(0,100000);
	}
</script>
<?php include "menu.html"; ?>
<script src="js/index.js"> </script>
<form action="" method="post">
<button name="serverlog" class="click">Download log file</button>
</form>
<?php
  if (!file_exists("$logs")) {
	echo "Log File Not Exists!!";
	exit();
  } else {
	echo "<br>"."%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%###Logs Starts###%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"."<br>";
	//echo "<pre>".file_get_contents("$logs")."</pre>";
	//foreach ($logs as $b){echo $b."<br>";}
	echo "<pre>".tailFile($logs, 200)."</pre>";
	echo "%%%%%%%%%%%%%%%%%%%Logfile END!! Filesize:".$log_size."MB!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%";
	exit();
  }
?>
</body>
</html>
