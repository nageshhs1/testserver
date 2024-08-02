<?php include "config.php"; ?>
<?php
session_start();
	if (isset($_SESSION['user']))
	{echo "USER:".$_SESSION['user']."!! Already Logged In!";
?>
	<a href="taskqueue.php">Goto Main Page</a>
	&nbsp;&nbsp;
	<a href="logout.php">Logout!!</a>
<?php
	}
	elseif (!isset($_SESSION['user']))
	{
	//date_default_timezone_set('Asia/Jakarta');
	$date = date('m/d/Y h:i:s a', time());

		if($_POST["action"] == "Login" && !empty($_POST["user"]) && !empty($_POST["passwd"]))
		{
		$user = $_POST["user"];
		$passwd = $_POST["passwd"];

		$command = escapeshellcmd("python pyss/login.py '$user' '$passwd'");
		$output = shell_exec($command);
		//  echo $output."<br>";

			if(strpos($output, 'Welcome') !== false)
			{
			//session_start();
			$url = $_SESSION['url'];
			$fileName = "$log_dir/userlogin.txt";
			// Turn on output buffering
			ob_start();
			$_SESSION['login']=session_id();
			$_SESSION['user'] = $user;
			$_SESSION['ip'] = $_SERVER['REMOTE_ADDR'];
			echo "User:".$_SESSION['user']." |";
			echo "Session Id:".$_SESSION['login']." |";
			echo "IP: ".$_SESSION['ip']." |";
			echo "from: ".$url." |";
			echo "login time: ".$date." |";
			$htmlStr = ob_get_contents();
			ob_end_clean();
			file_put_contents($fileName, $htmlStr." \n", FILE_APPEND);

				if($url == '' )
				{
				//echo "<a href=taskqueue.php>Go to Menu</a>" . "<br>". "<a href='logout.php'>Logout</a>" . "<br>";
				echo "<a href=taskqueue.php>Go to Menu</a>"." &nbsp;&nbsp;" ."<a href='logout.php'>Logout</a>";
				}
				else
				{
				header("location:" . $url);
				}
			}
			else
			{
			echo "Login Failed!!". "<br>";
			echo "<a href=login.php>Go to Login Page.</a>";
			}
		}
		else
		{
?>
<!DOCTYPE html>
<html >
	<head>
		<meta charset="UTF-8">
		<title>Login Page.</title>
	</head>
	<head>
		<link rel="stylesheet" type="text/css" href="css\style.css">
		<script src="js/prefixfree.min.js"> </script>
	</head>
	<body>
		<?php include "menu.html"; ?>
		<script src="js/index.js"> </script>
		<br />
		<form class="login-form" action="login.php" method="POST" align="center">
			<div class="form-group">
			<label form="user">User:</label>
			<input type="user" name="user" placeholder="User Name" class=form-control required/>
			</div>
			<div class="form-group">
			<label form="passwd">Password:</label>
			<input type="password" placeholder="Password" name="passwd" class=form-control required/>
			</div>
			<div class="form-action">
			<div class="col-sm-12"><a href="register.php" onclick="toggleForm()" class="pull-left font-bree font-2x">Sign Up</a><input type="submit" class="submit_btn btn pull-right" name="action" value="Login"/> <input type="button" value="Back" onClick="document.location.href='taskqueue.php';"/></div>
			</div>
		</form>
		<input type="hidden" name="redirurl" value="<? echo $_SERVER['HTTP_REFERER']; ?>" />
	</body>
</html>
<!--Login Form Ends-->
<?php
}
}
?>
