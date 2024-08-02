#!/usr/bin/python
import sys, os
import cgi, cgitb, sqlite3
from multiprocessing import Lock
from config import DB_PATH
cgitb.enable()

taskid = sys.argv[1]
file1 = "$log_dir/task/%s/log_eth.txt"%taskid
file2 = "$log_dir/task/%s/log_console_eth.txt"%taskid
log_dir = "$log_dir/task/%s/"%taskid

a ='''<?php include "config.php"; ?>
<?php
	$logs="%s";
	if(isset($_POST["setuplog"]))
                {
                $fileName = "%s";
		if( !file_exists($fileName) ) die("File not found");
                $type = filetype($fileName);
                header("Content-Disposition: attachment;filename=$fileName");
                header("Content-type: $type");
                header("Content-Transfer-Encoding: binary");
                header('Pragma: no-cache');
                header('Expires: 0');
                set_time_limit(0);
                readfile($fileName);
		exit();
        }
        elseif(isset($_POST["consolelog"]))
        {
                $fileName = $logs.$_POST['filename'];
                //$fileName = "%s";
		if( !file_exists($fileName) ) die("File not found");
                $type = filetype($fileName);
                header("Content-type: $type");
                header("Content-Disposition: attachment;filename=$fileName");
                header("Content-Transfer-Encoding: binary");
                header('Pragma: no-cache');
                header('Expires: 0');
                set_time_limit(0);
                readfile($fileName);
		exit();
        }
?>
<!DOCTYPE html>
<html>
        <head>
                <link rel="stylesheet" type="text/css" href="css\style.css">
                <script src="js/prefixfree.min.js"> </script>
        </head>
        <body>
                <nav class="animenu">
                 <ul class="animenu__nav">
                        <li>
                        <a href="">Download Logs</a>
                        </li>
                </ul>
                </nav>
                <script src="js/index.js"> </script>
                <form action="" method="post">
		<select name="filename" id="filename">
			<?php
				//$files=preg_grep('~\.(txt)$~', scandir($logs));
				$files=preg_grep('/^log/', scandir($logs));
				foreach ($files as $line) {
				echo "<option value='$line'>$line</option>";
        		        }
	           	 ?></select>
                        &nbsp;&nbsp;
                        <button name="consolelog" class="click">Download File</button>
                </form>
        </body>
</html>'''%(log_dir,file1,file2)
print a
