<?php
if($_POST["submit"] == "Add" && !empty($_POST["name"]) && !empty($_POST["ipaddress"])) {
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

  //Calling python script with parameters to add in to database.
  $command = escapeshellcmd("python pyss/addsetup.py '$name' '$ipaddress' '$url_status' '$url_dispatch' '$url_stop' '$url_free' '$url_create_dir' '$url_log' '$url_tc'");
  $output = shell_exec($command);

  echo "Done";
  header("Location:setup.php");

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
<form method="post" action="addsetup.php">
<table bgcolor="#C4C4C4" align="" width="580" border="0">
<tr>
<td  align="center"colspan="2"><font color="#0000ff" size="6">Add Setup</font></td>
</tr>
<tr>
<td width="312"></td>
<td width="172"> </td>
</tr>
<tr>
<td>Setup Name </td>
<td><input type="text" placeholder="Setup Name" name="name"  /></td>
</tr>
<tr>
<td>IP Address</td>
<td><input type="text" placeholder="IP Address" name="ipaddress"  /></td>
</tr>
<tr>
<td>URL Status</td>
<td><input type="text" placeholder="http://x.x.x.x/cgi-bin/auto_status.cgi" name="url_status" value="/cgi-bin/auto_status.cgi" /></td>
</tr>
<tr>
<td>URL Dispatch</td>
<td><input type="text" placeholder="http://x.x.x.x/cgi-bin/auto_dispatch.cgi" name="url_dispatch" value="/cgi-bin/auto_dispatch.cgi" /></td>
</tr>
<tr>
<td>URL Stop</td>
<td><input type="text" placeholder="http://x.x.x.x/cgi-bin/auto_stop.cgi" name="url_stop" value="/cgi-bin/auto_stop.cgi" /></td>
</tr>
<tr>
<td>URL Free</td>
<td><input type="text" placeholder="http://x.x.x.x/cgi-bin/auto_free.cgi" name="url_free" value="/cgi-bin/auto_free.cgi" /></td>
</tr>
<tr>
<td>URL Create Dir</td>
<td><input type="text" placeholder="http://x.x.x.x/tftpboot/" name="url_create_dir" value="/tftpboot/" /></td>
</tr>
<tr>
<td>URL Auto Live Logs</td>
<td><input type="text" placeholder="http://x.x.x.x/cgi-bin/auto_live_log.pl" name="url_log" value="/cgi-bin/auto_live_log.pl" /></td>
</tr>
<tr>
<td>URL Auto Live Test Case</td>
<td><input type="text" placeholder="http://x.x.x.x/auto_Live_testcase.html" name="url_tc" value="/auto_Live_testcase.html" /></td>
</tr>
<td align="center" colspan="2"><input type="submit" value="Add" name="submit"/> <input type="button" value="Back" onClick="document.location.href='setup.php';"/></td>
</table>
</form>
</body>
<div align="">Please Add Setup Details</div>
</html>
<?php
}
?>
