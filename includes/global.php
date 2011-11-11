<?php

$link = mysql_connect("localhost", "db",'pass')
   or die("Could not connect : " . mysql_error());

mysql_select_db("db",$link) or die("Could not select database");

function getPerformerFromRoomName($rm="")
  {
    $rm = explode("#__P__",$rm);
    
    if(isset($rm[1]))
      {
        return $rm[1];
      }  
    return false;
  }

function pruneInactiveUsers()
  {
    /*
     * Do garbage collection (records which have not been touched
     * in the last 60 seconds). NOTE: client sends refresh every 30 seconds.
     * to be safe, I'm bumping the cleanup window -- this doesn't have
     * any effect on the client user list, which is updated via irc, this
     * is simply the working table, where precise lists with to-the-second
     * accuracy aren't necessary.
     *
     * Get expired records and copy them to `audit` table
     */
    
    $q = "  SELECT  user_id,
                    username,
                    challenge,
                    room,
                    room_join_time,
                    last_touch_time,
                    is_performer,
                    bill_per_minute 
            FROM active_users 
            WHERE TIMESTAMPDIFF(SECOND,last_touch_time,now()) >= 60";
    $r = mysql_query($q);
    
    if(mysql_num_rows($r) > 0)
      {
        /*
         * create the DELETE, INSERT queries
         */
        $del = "";
        $ins = "";
        while($d = mysql_fetch_assoc($r))
          {
            $user_id            = $d['user_id'];
            $username           = $d['username'];
            $challenge          = $d['challenge'];
            $room               = $d['room'];
            $room_join_time     = $d['room_join_time'];
            $last_touch_time    = $d['last_touch_time'];
            $is_performer       = $d['is_performer'];
            $bill_per_minute    = $d['bill_per_minute'];
            
            $del .= $user_id.",";
            $ins .= "($user_id,'$username','$challenge','$room','$room_join_time','$last_touch_time',$is_performer,$bill_per_minute),";
          }
        
        /*
         * lose trailing characters
         */
        $del = substr($del,0,-1);
        $ins = substr($ins,0,-1);  
          
        $dq = "DELETE FROM active_users WHERE user_id IN ( $del )";
        $iq = "INSERT INTO audit(user_id,username,challenge,room,room_join_time,last_touch_time,is_performer,bill_per_minute) VALUES $ins";
    
        
        mysql_query($dq);
        mysql_query($iq);
     }
  }
?>