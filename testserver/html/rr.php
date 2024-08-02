<?php
        session_start();
        include "config.php";
	#function results($Input){
	#echo $taskid = $Input;
	$taskid = $argv[1];
	exec("sudo chmod a+rwx $result_dir/$taskid -R");
	$result_path = "$result_dir/$taskid";
	$fileName2 = "$result_path/results.htm";
	$tkid = "$result_path/*.htm";
	if ( !file_exists($fileName2) ){
		echo $files = glob($tkid);
		foreach($files as $file){
			$obStr = file_get_contents ($file);
	 		file_put_contents($fileName2, $obStr." \n", FILE_APPEND);
		}
		}
	#return (print_r($fileName));
	#}
?>
