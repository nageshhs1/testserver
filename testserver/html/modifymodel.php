<?php
	$board_id = $_POST["board_id"];
	$setup_id = $_POST["setup_id"];
	$model = $_POST["model"];
	if($_POST["submit"] == "Modify" && !empty($_POST["setup_id"]) && !empty($_POST["model"])) {
		$model = $_POST["model"];
		$eth = $_POST["eth"];
		$atm = $_POST["atm"];
		$ptm = $_POST["ptm"];

	//Calling python script with parameters to add in to database.
	$command = escapeshellcmd("python pyss/modifymodel.py '$setup_id' '$model' '$eth' '$atm' '$ptm' '$board_id'");
	$output = shell_exec($command);
	echo "Done";
	header('Location:models.php');

?>
<?php
} else {
	//Calling python script to display setup database.
	$command = escapeshellcmd("python pyss/modifymodel1.py '$setup_id' '$board_id' '$model'");
	//$command = escapeshellcmd("python pyss/modifymodel1.py $board_id");
	$output = shell_exec($command);
	print_r($output);
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Modify Model/Board.</title>
</head>
<body>
</body>
</html>
<?php
}
?>
