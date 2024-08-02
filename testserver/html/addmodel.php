<?php
if($_POST["submit"] == "Add" && !empty($_POST["setup_id"]) && !empty($_POST["model"])) {
  $setup_id = $_POST["setup_id"];
  $board_id = $_POST["board_id"];
  $model = $_POST["model"];
  $eth = $_POST["eth"];
  $atm = $_POST["atm"];
  $ptm = $_POST["ptm"];

  //Calling python script with parameters to add in to database.
  $command = escapeshellcmd("python pyss/addmodel.py '$setup_id' '$board_id' '$model' '$eth' '$atm' '$ptm'");
  $output = shell_exec($command);

  echo "Done";
  header("Location:models.php");
?>
<?php
} else {
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" type="text/css" href="css\style.css">
<script src="js/prefixfree.min.js"> </script>
<title>Add Model Page.</title>
</head>

<body>
<?php include "menu.html"; ?>
<script src="js/index.js"> </script>
<form method="post" action="addmodel.php">
<table bgcolor="#C4C4C4" align="" width="580" border="0">
<tr>
<td  align="center"colspan="2"><font color="#0000ff" size="6">Add Model/Board</font></td>
</tr>
<tr>
<td width="312"></td>
<td width="172"> </td>
</tr>
<tr>
<td>Setup Id </td>
<td><input type="text" placeholder="Setup Id" name="setup_id"  /></td>
</tr>
<tr>
<td>Board Id </td>
<td><input type="text" placeholder="Board Id" name="board_id"  /></td>
</tr>
<tr>
<td>Model Number</td>
<td><input type="text" placeholder="GRX550_2000_x_x" name="model"  /></td>
</tr>
<tr>
<td>WAN Mode ETH</td>
<td><input type="text" placeholder="0 or 1" name="eth" /></td>
</tr>
<tr>
<td>WAN Mode ATM</td>
<td><input type="text" placeholder="0 or 1" name="atm" /></td>
</tr>
<tr>
<td>WAN Mode PTM</td>
<td><input type="text" placeholder="0 or 1" name="ptm" /></td>
</tr>
<td align="center" colspan="2"><input type="submit" value="Add" name="submit"/> <input type="button" value="Back" onClick="document.location.href='setup.php';"/></td>
</table>
</form>
</body>
<div align="">Please Add Board Info.</div>
</html>
<?php
}
?>

