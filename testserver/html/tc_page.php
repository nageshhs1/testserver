<?php
        session_start();
	include "config.php";
	//$tc_path = "/testserver/db/testcase/";
	if(!empty($_POST['check_list']) && !empty($_POST["tc_grp"]) ) {
		$tc_grp = $_POST["tc_grp"];
		//$fileName = "tc_list.txt";
		$fileName = $tc_path.$tc_grp.".txt";
		if( file_exists($fileName) ){ die("File Already Exists! Please Provide Different Name!!");
		}else{
			//if(!empty($_POST["tc_grp"])) {
			if (strpos(file_get_contents("$list_tcgrp"),$_POST["tc_grp"]) !== false) {
				die("File Already Exists in group! Please Provide Different name!!!!");
			} else {
				$myfile = fopen("$list_tcgrp", "a") or die("Unable to open file!");
				fwrite($myfile, "\n". strtoupper($tc_grp));
				fclose($myfile);
			}
		//}
			foreach($_POST['check_list'] as $check) {
			ob_start();
			echo $check;
			$obStr = ob_get_contents();
			ob_end_clean();
			file_put_contents($fileName, $obStr." \n", FILE_APPEND);
			}
		}
	}
?>
<!DOCTYPE html>
<html>
        <head>
         <link rel="stylesheet" type="text/css" href="css\style.css">
         <script src="js/prefixfree.min.js"> </script>
	<script>
	function myFunction() {
	    var x = document.getElementById("myCheck");
	    if (x.checked == true){
	    	x.checked = false;
	    }else {
	    	x.checked = true;
	    }
	}
	</script>
	<script>
	 function checkAll(ele) {
	     var checkboxes = document.getElementsByTagName('input');
	     if (ele.checked) {
	         for (var i = 0; i < checkboxes.length; i++) {
	             if (checkboxes[i].type == 'checkbox') {
	                 checkboxes[i].checked = true;
	             }
	         }
	     } else {
	         for (var i = 0; i < checkboxes.length; i++) {
	             console.log(i)
	             if (checkboxes[i].type == 'checkbox') {
	                 checkboxes[i].checked = false;
	             }
	         }
	     }
	 }
	</script>
        </head>
        <body>
         <?php include "menu.html"; ?>
         <script src="js/index.js"> </script>
         <?php
	  $command = escapeshellcmd('pyss/tclist.py');
          $output = shell_exec($command);
          print_r($output);
         ?>
        </body>
</html>
