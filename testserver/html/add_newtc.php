<?php
if($_POST["submit"] == "Add" && !empty($_POST["tc_name"])) {
  $tc_name = $_POST["tc_name"];
  $tc_grp = $_POST["tc_grp"];
  $description = $_POST["description"];

  //Calling python script with parameters to add in to database.
  $command = escapeshellcmd("python pyss/add_newtc.py '$tc_name' '$tc_grp' '$description'");
  $output = shell_exec($command);

  echo "Done";
  header("Location:tc_page.php");

?>
<?php
} else {
?>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="css\style.css">
<script src="js/prefixfree.min.js"> </script>
<meta charset="UTF-8">
<title>Add Setup Page.</title>
</head>

<body>
<?php include "menu.html"; ?>
<script src="js/index.js"> </script>
<form method="post" action="add_newtc.php">
<table bgcolor="#C4C4C4" align="" width="580" border="0">
<tr>
<td  align="center"colspan="2"><font color="#0000ff" size="6">Add New TestCase</font></td>
</tr>
<tr>
<td width="312"></td>
<td width="172"> </td>
</tr>
<tr>
<td>TestCase Name </td>
<td><input type="text" placeholder="TestCase Name" name="tc_name"  /></td>
</tr>
<tr>
<td>TestCase Group </td>
<td><input type="text" placeholder="TestCase Group" name="tc_grp"  /></td>
</tr>
<tr>
<td>TestCase Description </td>
<td><input type="text" placeholder="TestCase description" name="description"  /></td>
</tr>
<td align="center" colspan="2"><input type="submit" value="Add" name="submit"/> <input type="button" value="Back" onClick="document.location.href='tc_page.php';"/></td>
</table>
</form>
</body>
<div align="">Please Add New TestCase</div>
</html>
<?php
}
?>
