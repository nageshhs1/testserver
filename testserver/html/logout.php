<?php
// Initialize the session.
session_start();
$_SESSION['url'] = $_SERVER['REQUEST_URI'];

echo "User: ".$_SESSION['user']."<br />"."Logout!"."<br />";

// If you are using session_name("something"), don't forget it now!
//session_name("user");
/*echo "SessionId: ". session_id(). "<br />";
echo "_SESSION: ".$_SESSION['login']. "<br />";
echo "User:".$_SESSION['user']. "<br />";
echo "IP: ".$_SESSION['ip']."<br>";
*/
// Unset all of the session variables.
//$_SESSION = array();

// If it's desired to kill the session, also delete the session cookie.
// Note: This will destroy the session, and not just the session data!
/*if (ini_get("session.use_cookies")) {
$params = session_get_cookie_params();
setcookie(session_name(), '', time() - 42000,
$params["path"], $params["domain"],
$params["secure"], $params["httponly"]
);
}
*/
// Finally, destroy the session.
session_destroy();
setcookie(PHPSESSID,session_id(),time()-1);

// Show Redirect url to login again.
echo "<a href='login.php'>Login Again</a>" . "<br>";
?>
