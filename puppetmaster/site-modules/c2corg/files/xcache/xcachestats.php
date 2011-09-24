<?php

$id = (isset($_SERVER["QUERY_STRING"])) ? (int)$_SERVER["QUERY_STRING"] : 0;

print(json_encode(xcache_info(XC_TYPE_PHP, $id)));

?>
