<?php
	if ( confirm("Not Suported!") ){
	echo "stopping...";
	header("Refresh: 10; url=taskqueue.php");
	}
?>
<!DOCTYPE html>
<html> 
    <head> 
        <script type="text/javascript">
        function changecolors() {    
            var t = setInterval('change()',1000); 
        } 

        function change() {
            var color = document.body.style.background;

            if(color == "silver") {
                document.body.style.background = "gray";
            } else {
                document.body.style.background = "silver";
            }
        } 
       </script>
    </head> 
    <body onload="javascript:changecolors()"> 
    </body> 
</html>
