<?php
$list_tcgrp = "/testserver/html/list_tcgrp.txt";
$tc_path = "/testserver/db/testcase/";
$log_dir = "/testserver/db/log/";
$result_dir = "/testserver/db/log/task";
function getDB() {
	$dbConnection = new PDO("sqlite:/testserver/db/bsptestserver.db");
        $dbConnection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $dbConnection;
}
?>
