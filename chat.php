<?php

require_once("includes/global.php");
  
$username = $_POST['user'];

/*
 * TODO: create a posting system for this
 */
$room               = "#lobby";
//$room             = "#__P__performer1";
 
/*
 * Is this username valid?
 */
$q = "  SELECT  user_id,
                is_performer
        FROM temp_accounts 
        WHERE username = '".mysql_real_escape_string($username)."'";
$r = mysql_query($q);

if(mysql_num_rows($r) < 1)
  {
    /*
     * username not found
     */
    echo "Unknown user";
    exit;
  }

$i = mysql_fetch_assoc($r);

$user_id            = $i['user_id'];
$is_performer       = $i['is_performer'];

/*
 * is this user already logged in?
 */
$q = "SELECT user_id,room FROM active_users WHERE username = '".mysql_real_escape_string($username)."'";
$r = mysql_query($q);

if(mysql_num_rows($r) > 0)
  {
    /*
     * already logged in.  Kill previous record.
     * TODO: run this as an audit deletion
     */
    mysql_query("DELETE FROM active_users WHERE user_id = $user_id");
  }

/*
 * ok, create an entry in `active_users`. The idea is mainly to
 * create the private/public key challenge info which will be checked
 * on each user audit.
 *
 * challenge is sha1(private_key + user_id); every user audit, user
 * sends username + private_key; audit.php finds username, gets
 * user_id, performs equivalent sha1, and compares.  This should work
 * well to keep the connection somewhat secure.
 */
 
/*
 * If this is a performers room, we want to store this information
 * in the active_users record.  We determine if this is a performer's room
 * by checking the $room name itself: when a performer creates a room,
 * the room is named using this syntax: `#__P__PERFORMERNAME`. 
 */

$rPerformer = getPerformerFromRoomName($room);

if($rPerformer)
  {
    /*
     * get billing rate for this performer.
     */
    $q = "  SELECT  bill_per_minute 
            FROM temp_accounts 
            WHERE username = '".mysql_real_escape_string($rPerformer)."' 
            LIMIT 1";
    $r = mysql_query($q);
    
    if(mysql_num_rows($r) < 1)
      {
        /*
         * hm; what exactly is creating rooms with performer syntax
         * for performers that don't exist? TODO: admin email.
         */
        echo "System error.";
        exit;  
      }
      
    list($bill_per_minute) = mysql_fetch_row($r);
  }
else
  {
    $bill_per_minute  = 0.00;
  }

$private_key = md5(uniqid(rand(), true));
$challenge = sha1($private_key.$user_id);

$q = "  INSERT INTO active_users(
          user_id,
          bill_per_minute,
          username,
          private_key,
          challenge,
          room,
          room_join_time,
          last_touch_time,
          is_performer)   
        VALUES(
          $user_id,
          $bill_per_minute,
          '".mysql_real_escape_string($username)."',
          '$private_key',
          '$challenge',
          '$room',
          now(),
          now(),
          $is_performer)";

$r = mysql_query($q);

if(mysql_affected_rows() < 1)
  {
    echo "unable to log in.";
    exit;  
  }

?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="-1" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">	
<meta http-equiv="Content-Language" content="en-us" />
<meta name="ROBOTS" content="ALL" />
<meta name="Copyright" content="Copyright (c) Unified Applications Inc." />
<meta http-equiv="imagetoolbar" content="no" />
<meta name="MSSmartTagsPreventParsing" content="true" />
<title>chat</title>
</head>
<body bgcolor="#ffffff">

<div style="width:555px; height:480px; float:left;">
  
  <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0" width="555" height="480" id="chat" align="middle">
  <param name="allowScriptAccess" value="sameDomain" />
  <param name="movie" value="chat.swf" /><param name="quality" value="high" />
  <param name="bgcolor" value="#ffffff" />
  <PARAM NAME="FlashVars" VALUE="nick=<?php echo $username; ?>&startRoom=<?php echo $room; ?>&token=<?php echo $challenge; ?>" />
  
  <embed src="chat.swf" quality="high" bgcolor="#ffffff" width="555" height="480" name="chat" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" FlashVars="nick=<?php echo $username; ?>&startRoom=<?php echo $room; ?>&token=<?php echo $challenge; ?>" />
  
  </object>

</div>

<div style="width:320px; height:480px; float:left;">
  
<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0" width="320" height="480" id="broadcaster" align="middle">
<param name="allowScriptAccess" value="sameDomain" />

<param name="movie" value="broadcaster.swf" /><param name="quality" value="high" /><param name="bgcolor" value="#ffffff" />

<embed src="broadcaster.swf" quality="high" bgcolor="#ffffff" width="320" height="480" name="broadcaster" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
</object>

</div>




</body>
</html>
