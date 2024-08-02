<?php
	if($_POST["action"] == "Submit" && !empty($_POST["image"]) && !empty($_POST["user"]))
	{
	$image = $_POST["image"];
	$model = $_POST["model"];
	$user = $_POST["user"];
	$email = $_POST["email"];
	$wan = $_POST["wan"];
	$ttype = $_POST["ttype"];
	$stype = $_POST["stype"];
	$meta = $_POST["meta"];
	$ltask = $_POST["ltask"];
	$stime = date("Y-m-d H:i:s");
	$tc_grp = $_POST["tc_grp"];

	$wan = implode(",", $wan);
	//Calling python script with parameters to save in to database.
	$command = escapeshellcmd("python pyss/insert.py '$image' '$model' '$user' '$email' '$wan' '$ttype' '$stype' '$meta' '$ltask' '$stime' '$tc_grp'");
	$output = shell_exec($command);

	echo "Ok";
	header("Location:taskqueue.php");
	//exit;
?>
<?php
	} else {
?>
<!DOCTYPE html>
<html lang="en">
	<head>
	<link rel="stylesheet" type="text/css" href="css\style.css">
	<script src="js/prefixfree.min.js"> </script>
	<meta charset="UTF-8">
	<title>New Task Page.</title>
	<script>
		function checkTextField(field) {
		    if (field.value == '') {
		        alert("Image, User, Email fields Cannot Be Empty!");
		    }
		}
	</script>
	</head>
	<body>
	<?php include "menu.html"; ?>
	<script src="js/index.js"> </script>
	<form action="insert.php" method="POST" enctype="multipart/form-data">
	<table bgcolor="#C4C4C4" align="" width="780" border="0">
	<tr><td align="center"colspan="2"><font color="#0000FF" size="6">Add New Task</font></td></tr>
	<tr><td width="412"></td><td width="272"> </td></tr>
	<tr>
	<td><b>Image Path:</b></td>
	<td><input type="text" name="image" id="image" required/></td>
	</tr>
	<tr>
	<td><b>Model Number:</b></td>
	<td><select name="model" id="model">
            <option hidden="false">Please select Model Number</option>
            <?php
		foreach(file('list_model.txt', FILE_IGNORE_NEW_LINES) as $line) {
		   echo "<option value=\"$line\">$line</option>"."\n";
		}
	    ?> 
	    </select></td>
	</tr>
	<tr>
	<td><b>User Name:</b></td>
	<td><input type="text" name="user" id="user" required/></td>
	</tr>
	<tr>
	<td><b>User Email:</b></td>
	<td><input type="text" name="email" id="email" onblur="checkTextField(this);"></td>
	</tr>
	<tr>
	<td><b>WAN Mode:</b></td>
	<td><select name="wan[]" id="wan" multiple="multiple">
	    <option value="eth">ETH</option>
	    <option value="atm">ATM</option>
	    <option value="ptm">PTM</option>
	    <option value="all">ALL</option>
	    </select></td>
	</tr>
	<tr>
	<td><b>Test Type:</b></td>
	<td><select name="ttype" id="ttype">
	    <option value="smoke">Smoke</option>
	    <option value="full">Full</option>
	    <option value="mpe">MPE</option>
	    </select></td>
	</tr>
        <tr>
        <td><b>Sub Type:</b></td>
	<td><select name="stype" id="stype">
	    <option value="standard">Standard</option>
	    <option value="failonly">FailOnly</option>
	    </select></td>
	</tr>
        <tr>
        <td><b>Meta Info:</b></td>
        <td><textarea name = "meta" ></textarea></td>
        </tr>
        <tr>
        <td><b>Last Task Id:</b></td>
        <td><input type="text" name="ltask" id="ltask"></td>
        </tr>
	<tr>
	<td><b>Select TestCase Group:</b></td>
	<td><select name="tc_grp" id="tc_grp" multiple="multiple" size="3">
            <option hidden="false">Please select Test Group</option>
            <?php
		foreach(file('list_tcgrp.txt', FILE_IGNORE_NEW_LINES) as $line) {
		   echo "<option value=\"$line\">$line</option>"."\n";
		}
	    ?> 
	    </select></td>
	</tr>
	<td align="center" colspan="2"><input type="submit" name="action" value="Submit"/> <input type="button" value="Back" onClick="document.location.href='taskqueue.php';"/></td>
	</table>
	</form>
	</body>
</html>
<?php
}
?>
