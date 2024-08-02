<?php
	$setup_id = $_POST["setup_id"];
	if($_POST["submit"] == "Modify" && !empty($_POST["name"]) && !empty($_POST["ipaddress"])) {
	$name = $_POST["name"];
	//$setup_id = $_POST["setup_id"];
	$ipaddress = $_POST["ipaddress"];
	$url_status = $_POST["url_status"];
	$url_dispatch = $_POST["url_dispatch"];
	$url_stop = $_POST["url_stop"];
	$url_free = $_POST["url_free"];
	$url_create_dir = $_POST["url_create_dir"];
	$url_log = $_POST["url_log"];
	$url_tc = $_POST["url_tc"];

	//Calling python script with parameters to update database.
	$command = escapeshellcmd("python pyss/modifysetup.py '$name' '$ipaddress' '$url_status' '$url_dispatch' '$url_stop' '$url_free' '$url_create_dir' '$url_log' '$url_tc' '$setup_id'");
	$output = shell_exec($command);
	echo "Done";
	header('Location:setup.php');

?>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="css\style.css">
<script src="js/prefixfree.min.js"> </script>
<meta charset="UTF-8">
<title>Modify Setup.</title>
</head>
<body>
<?php include "menu.html"; ?>
<script src="js/index.js"> </script>
<?php
	} else {
	//Calling python script to display setup database.
	$command = escapeshellcmd("python pyss/modifysetup1.py $setup_id");
	$output = shell_exec($command);
	print_r($output);
?>
</body>
</html>
<?php
}
?>
