<?php
session_start();
$subfolder = "auto_log";
$status_name = "status.txt";
$status_value = "";

  if (!file_exists("$subfolder/$status_name")) {
	 $status_value = "free";
  } else {
// Check if a text file exists. If not create one and initialize it to zero.
  // Read the current value of our counter file
    $f = fopen("$subfolder/$status_name","r");
    $status_value = fread($f, filesize("$subfolder/$status_name"));
    fclose($f);
  }
  chop($status_value);
  echo $status_value;
?>

