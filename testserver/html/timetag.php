<?php
session_start();
$counter_name = "counter.txt";
$timetag_name = "timetag.txt";
$file_lock_name = "filelock.txt";

$file_lock = fopen($file_lock_name,"w+");
if (flock($file_lock,LOCK_EX)) {
  if (!file_exists($counter_name)) {
    $f = fopen($counter_name, "w");
    fwrite($f,"0");
    fclose($f);
  }
// Check if a text file exists. If not create one and initialize it to zero.
  if (!file_exists($timetag_name)) {
    $f = fopen($timetag_name, "w");
    fwrite($f,"0123456789");
    fclose($f);
  }
  // Read the current value of our counter file
  $f = fopen($counter_name,"r");
  $counterVal = fread($f, filesize($counter_name));
  $curr_time = date("Yhis");
  fclose($f);

  $f = fopen($timetag_name,"r");
  $last_time = fread($f, filesize($timetag_name));
  $curr_time = date("YmdHis");
  fclose($f);

// Has visitor been counted in this session?
// If not, increase counter value by one
 if ( strcasecmp( $last_time, $curr_time ) != 0 )
        $counterVal = 1;
 else
        $counterVal++;
  $f = fopen($counter_name, "w");
  fwrite($f, $counterVal);
  fclose($f);

  $f = fopen($timetag_name, "w");
  fwrite($f, $curr_time);
  fclose($f);
  fclose($file_lock);
  echo $curr_time . "_" . $counterVal;
  #echo "curr time :" . $curr_time . "<p>";
  #echo "last time :" . $last_time;
}
?>
