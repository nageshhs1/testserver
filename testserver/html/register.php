<?php
if($_POST["submit"] == "save" && !empty($_POST["name"]) && !empty($_POST["password"])) {
  $user = $_POST["name"];
  $password = $_POST["password"];

  //Calling python script with parameters to save in to database.
  $command = escapeshellcmd("python pyss/register.py '$user' '$password'");
  $output = shell_exec($command);

  echo "Success";
  header("location:login.php");

?>
<?php
} else {
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Registration Page.</title>
<link rel="stylesheet" type="text/css" href="css\style.css">
<script src="js/prefixfree.min.js"> </script>
</head>

<body>
<?php include "menu.html"; ?>
<script src="js/index.js"> </script>
<form method="post" action="register.php">
<table bgcolor="#C4C4C4" align="center" width="380" border="0">
<tr>
<td  align="center"colspan="2"><font color="#0000FF" size="6">Registration Form</font></td>
</tr>
<tr>
<td width="312"></td>
<td width="172"> </td>
</tr>
<tr>
<td>User Name </td>
<td><input type="text" placeholder="User Name" name="name" required/></td>
</tr>
<tr>
<td> Password </td>
<td><input type="password" placeholder="Password" name="password" required/></td>
</tr>
<td align="center" colspan="2"><input type="submit" value="save" name="submit" /> <input type="submit" value="Back" onClick="history.go(-1);"/></td>
</table>
</form>
</body>
<div align="center">Please Submit User Name and Password!</div>
</html>
<?php
}
?>
