<html>
<head>
<script>
</script>
<title>BSP/MPE FW Automation Test</title>
</head>
<frameset rows="100%,0" frameborder="yes" framespacing=1>
   <?php
      $command = escapeshellcmd('pyss/check_q.py');
      $output = shell_exec($command);
      if ($output!=0){
	print "<frame name=\"main\" src=\"taskqueue.php\" marginheight=2 marginwidth=5 scrolling=auto>";
      }else{
	print "<frame name=\"main\" src=\"test_history.php\" marginheight=2 marginwidth=5 scrolling=auto>";
      }
  ?>
</frameset>
</html>


