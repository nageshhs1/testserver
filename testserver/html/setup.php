<?php
	session_start();
	if(($_SERVER['REQUEST_METHOD'] === 'POST') && ($_POST["del"] || $_POST["Modify"] || $_POST["Reserve"]))
	{
		if(!$_SESSION['login']==session_id())
		{
			echo "Please login to delete task"."<br>";
			echo "<a href='login.php'>Login</a>"."<br>";
			header("location:login.php");
			exit("");
		}
	}
?>
<?php include"menu.html";?>
<?php include "config.php"; ?>
<?php
	//date_default_timezone_set('Asia/Jakarta');
	$date=date('m/d/Y h:i:sa',time());
	$_SESSION['url'] = $_SERVER['REQUEST_URI'];
	if($_POST["del"] && $_POST["setup_id"])
	{
		if(!$_SESSION['login'] == session_id())
		{
			echo"2Please login to delete task"."<br>";
			echo $_SESSION['login']."<br>";
			echo "SessionId: ".session_id()."<br>";
			echo "_SESSION: ".$_SESSION['login']."<br>";
			header("Location:login.php");
		}
		else
		{
			$fileName = "$log_dir/setupdeletedbyuser.txt";
			ob_start();
			echo "User: ".$_SESSION['user']." |";
			echo "SessionId: ".session_id()." |";
			echo "IP: ".$_SESSION['ip']." |";
			echo "time: ".$date." |";
			echo $setup_id." |";
			echo "setupdel: ".$_POST['setup_id']." |";
			$obStr = ob_get_contents();
			ob_end_clean();
			file_put_contents($fileName, $obStr." \n", FILE_APPEND);

			//Call Python script to delete task from database
			if($_SESSION['user'] == 'admin')
			{
			$setup_id=$_POST['setup_id'];
			$output=shell_exec("python pyss/delsetup.py $setup_id");
			echo $output;
			}
			else
			{
			echo '<script language="javascript">';
			echo 'alert("Not Admin User!")';
			echo '</script>';
			//header("Location:setup.php");
			//exit("");
			}
		}
	}
	elseif($_POST["modelInfo"] && $_POST["setup_id"])
	{
		//$setup_id = $_POST['setup_id'];
		//$output = shell_exec("python pyss/showmodels.py $setup_id");
	}
	elseif($_POST["Modify"] && $_POST["setup_id"])
	{
		//$setup_id = $_POST['setup_id'];
		//$output = shell_exec("python pyss/showmodels.py $setup_id");
	}
	elseif($_POST["Reserve"] && $_POST["setup_id"])
	{
		$setup_id = $_POST['setup_id'];
		$output = shell_exec("python pyss/reserve.py $setup_id");
	}
		$command = escapeshellcmd('pyss/setup.py');
		$output = shell_exec($command);
		print_r($output);
?>

<!DOCTYPE html>
<html>
	<head>
	<link rel="stylesheet" type="text/css" href="css\style.css">
	<script src="js/prefixfree.min.js"> </script>
	<script src="js/index.js"> </script>
	</head>
	<body>
	<script>
		function DelId(element)
		{
			next_page='setup.php'
			r = element.parentNode.parentNode.rowIndex;
			l = element.parentNode.cellIndex;
			var myTable = document.getElementById('setuplist').tBodies[0];
			//get first cell of this row in the table
			setup_id = myTable.rows[r].cells[1].innerHTML;

			form = document.createElement('form');
			form.setAttribute('method', 'POST');
			form.setAttribute('action', next_page);

			//setoperation:del/...
			opt = 'del';
			myvar = document.createElement('input');
			myvar.setAttribute('name', opt);
			myvar.setAttribute('type', 'text');
			myvar.setAttribute('value', opt);
			form.appendChild(myvar);
			//testsetup_id
			myvar1 = document.createElement('input');
			myvar1.setAttribute('name', 'setup_id');
			myvar1.setAttribute('type', 'text');
			myvar1.setAttribute('value', setup_id);
			form.appendChild(myvar1);

			if (confirm("Delete All Boards? Require Admin Login!"))
			{
				document.body.appendChild(form);
				form.submit();
			}
		}
	</script>
	<script>
		function modelInfo(element)
		{
			next_page = 'models.php'
			r = element.parentNode.parentNode.rowIndex;
			l = element.parentNode.cellIndex;
			var myTable = document.getElementById('setuplist').tBodies[0];
			//getfirstcellofthisrowinthetable
			setup_id = myTable.rows[r].cells[1].innerHTML;

			form = document.createElement('form');
			form.setAttribute('method', 'POST');
			form.setAttribute('action', next_page);
			//WriteCodetodisplaydetailInfoabttask

			//setoperation:modelInfo/...
			opt = 'modelInfo';
			myvar = document.createElement('input');
			myvar.setAttribute('name', opt);
			myvar.setAttribute('type', 'text');
			myvar.setAttribute('value', opt);
			form.appendChild(myvar);
			//testsetup_id
			myvar1 = document.createElement('input');
			myvar1.setAttribute('name', 'setup_id');
			myvar1.setAttribute('type', 'text');
			myvar1.setAttribute('value', setup_id);
			form.appendChild(myvar1);

			document.body.appendChild(form);
			form.submit();
		}
	</script>
	<script>
		function Modify(element)
		{
			next_page='modifysetup.php'
			//next_page = 'setup.php'
			r = element.parentNode.parentNode.rowIndex;
			l = element.parentNode.cellIndex;
			var myTable = document.getElementById('setuplist').tBodies[0];
			//getsetupidofthisrowinthetable
			setup_id = myTable.rows[r].cells[1].innerHTML;

			form = document.createElement('form');
			form.setAttribute('method', 'POST');
			form.setAttribute('action', next_page);

			//setoperation:modelInfo/...
			opt = 'Modify';
			myvar = document.createElement('input');
			myvar.setAttribute('name', opt);
			myvar.setAttribute('type', 'text');
			myvar.setAttribute('value', opt);
			form.appendChild(myvar);
			//testsetup_id
			myvar1 = document.createElement('input');
			myvar1.setAttribute('name', 'setup_id');
			myvar1.setAttribute('type', 'text');
			myvar1.setAttribute('value', setup_id);
			form.appendChild(myvar1);

			if (confirm("Really Want to modfiy Setup?"))
			{
				document.body.appendChild(form);
				form.submit();
			}
		}
	</script>
	<script>
                function Reserve(element)
                {
                        next_page = 'setup.php'
                        r = element.parentNode.parentNode.rowIndex;
                        l = element.parentNode.cellIndex;
                        var myTable = document.getElementById('setuplist').tBodies[0];
                        //getsetupidofthisrowinthetable
                        setup_id = myTable.rows[r].cells[1].innerHTML;

                        form = document.createElement('form');
                        form.setAttribute('method', 'POST');
                        form.setAttribute('action', next_page);

                        //set operation:Reserve Setup/...
                        opt = 'Reserve';
                        myvar = document.createElement('input');
                        myvar.setAttribute('name', opt);
                        myvar.setAttribute('type', 'text');
                        myvar.setAttribute('value', opt);
                        form.appendChild(myvar);
                        //test setup_id
                        myvar1 = document.createElement('input');
                        myvar1.setAttribute('name', 'setup_id');
                        myvar1.setAttribute('type', 'text');
                        myvar1.setAttribute('value', setup_id);
                        form.appendChild(myvar1);

			if (confirm("Required Login to Reserve Setup!!"))
			{
				document.body.appendChild(form);
				form.submit();
			}
                }
	</script>
	</body>
</html>
