<?php include "menu.html"; ?>
<?php include "config.php"; ?>
<?php
	//date_default_timezone_set('Asia/Jakarta');
	$date = date('m/d/Y h:i:s a', time());
        session_start();
	$_SESSION['url'] = $_SERVER['REQUEST_URI'];
	if( $_POST["del"] && $_POST["board_id"] )
	{
		if(!$_SESSION['login']==session_id())
		{
			echo "2Please log in to delete task"."<br>";
			echo $_SESSION['login']."<br>";
			echo "SessionId: ". session_id(). "<br />";
			echo "_SESSION: ".$_SESSION['login']. "<br />";
			header("location:login.php");
		}
		else
		{
			$fileName = "$log_dir/modeldeletedbyuser.txt";
			$setup_id = $_POST['setup_id'];
			$board_id = $_POST['board_id'];
			$model = $_POST['model'];
			ob_start();
			echo "User:".$_SESSION['user']. " |";
			echo "SessionId: ". session_id(). " |";
			echo "IP: ".$_SESSION['ip']." |";
			echo "time: ".$date." |";
			echo "setup id". $_POST['setup_id']. " |";
			echo "del board". $_POST['board_id']. " |";
			$obStr = ob_get_contents();
			ob_end_clean();
			file_put_contents($fileName, $obStr." \n", FILE_APPEND);

			//Call Python script to delete task from database
			if($_SESSION['user'] == 'admin')
			{
			$command = escapeshellcmd("python pyss/delmodel.py '$setup_id' '$board_id' '$model'");
			$output = shell_exec($command);
			echo $output;
			}
                        else
                        {
                        echo '<script language="javascript">';
                        echo 'alert("Not Login as admin!")';
                        echo '</script>';
                        header("Location:models.php");
                        }
		}
	}
		$setup_id = $_POST['setup_id'];
		$command = escapeshellcmd("python pyss/models.py $setup_id");
		$output = shell_exec($command);
		print_r($output);
?>
<!DOCTYPE html>
<html >
<head>
<link rel="stylesheet" type="text/css" href="css\style.css">
<script src="js/prefixfree.min.js"> </script>
<script src="js/index.js"> </script>
</head>
<body>
	<script>
		function DelId(element)
		{
			next_page = 'models.php'
                        r = element.parentNode.parentNode.rowIndex;
                        l = element.parentNode.cellIndex;
                        var myTable = document.getElementById('model').tBodies[0];
                        //get board id of this row in the table
                        setup_id = myTable.rows[r].cells[0].innerHTML;
                        board_id = myTable.rows[r].cells[1].innerHTML;
                        model = myTable.rows[r].cells[2].innerHTML;

                        form = document.createElement('form');
                        form.setAttribute('method', 'POST');
                        form.setAttribute('action', next_page);

                        //set operation : modelInfo/...
                        opt = 'del';
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
                        //test board_id
                        myvar2 = document.createElement('input');
                        myvar2.setAttribute('name', 'board_id');
                        myvar2.setAttribute('type', 'text');
                        myvar2.setAttribute('value', board_id);
                        form.appendChild(myvar2);
                        //test model_name
                        myvar3 = document.createElement('input');
                        myvar3.setAttribute('name', 'model');
                        myvar3.setAttribute('type', 'text');
                        myvar3.setAttribute('value', model);
                        form.appendChild(myvar3);

			if (confirm("Only Admin can Delete Board from Setup!"))
			{
				document.body.appendChild(form);
				form.submit();
			}
		}
	</script>
	<script>
		function Add(element)
		{
			next_page = 'addmodel.php'
                        r = element.parentNode.parentNode.rowIndex;
                        l = element.parentNode.cellIndex;
                        var myTable = document.getElementById('model').tBodies[0];
                        //get first cell of this row in the table
                        board_id=myTable.rows[r].cells[1].innerHTML;

                        form = document.createElement('form');
                        form.setAttribute('method', 'POST');
                        form.setAttribute('action', next_page);

                        //set operation: Add/...
                        opt = 'Add';
                        myvar = document.createElement('input');
                        myvar.setAttribute('name', opt);
                        myvar.setAttribute('type', 'text');
                        myvar.setAttribute('value', opt);
                        form.appendChild(myvar);
                        //test taskid
                        myvar1 = document.createElement('input');
                        myvar1.setAttribute('name', 'board_id');
                        myvar1.setAttribute('type', 'text');
                        myvar1.setAttribute('value', board_id);
                        form.appendChild(myvar1);

			if (confirm("Please login to Add!"))
			{
				document.body.appendChild(form);
				form.submit();
			}
		}
	</script>
	<script>
		function Modify(element)
		{
			next_page = 'modifymodel.php'
                        r = element.parentNode.parentNode.rowIndex;
                        l = element.parentNode.cellIndex;
                        var myTable = document.getElementById('model').tBodies[0];
                        //get board id of this row in the table
                        setup_id = myTable.rows[r].cells[0].innerHTML;
                        board_id = myTable.rows[r].cells[1].innerHTML;
                        model = myTable.rows[r].cells[2].innerHTML;

                        form = document.createElement('form');
                        form.setAttribute('method', 'POST');
                        form.setAttribute('action', next_page);

                        //set operation : modelInfo/...
                        opt = 'Modify';
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
                        //test board_id
                        myvar2 = document.createElement('input');
                        myvar2.setAttribute('name', 'board_id');
                        myvar2.setAttribute('type', 'text');
                        myvar2.setAttribute('value', board_id);
                        form.appendChild(myvar2);
                        //test model_name
                        myvar3 = document.createElement('input');
                        myvar3.setAttribute('name', 'model');
                        myvar3.setAttribute('type', 'text');
                        myvar3.setAttribute('value', model);
                        form.appendChild(myvar3);

			if (confirm("Please login to Modify!"))
			{
				document.body.appendChild(form);
				form.submit();
			}
		}
	</script>
</body>
</html>
