<?php

require_once("../includes/global.php");

$username   = $_GET['username'];
$challenge  = $_GET['challenge'];
$room       = '#'.$_GET['room'];

/*
 * valid user? 
 */
$q = "  SELECT  t1.user_id,
                t1.private_key,
                t1.challenge,
                t1.is_performer,
                t1.room_join_time,
                t1.last_touch_time,
                t1.bill_per_minute,
                t2.credits_remaining 
        FROM  active_users as t1,
              temp_accounts as t2 
        WHERE t1.user_id = t2.user_id 
        AND t1.username = '".mysql_real_escape_string($username)."' 
        AND t1.room = '".mysql_real_escape_string($room)."' 
        LIMIT 1";

$r = mysql_query($q);

if(mysql_num_rows($r) > 0)
  {   
    /*
     * check challenge
     */
    $i = mysql_fetch_assoc($r);
    
    $user_id            = $i['user_id'];
    $private_key        = $i['private_key'];
    $challenge          = $i['challenge'];
    $is_performer       = $i['is_performer'];
    $room_join_time     = $i['room_join_time'];
    $last_touch_time    = $i['last_touch_time'];
    $credits_remaining  = (float)$i['credits_remaining'];
    $bill_per_minute    = (float)$i['bill_per_minute'];
    
    if($challenge == sha1($private_key.$user_id))
      {
        /*
         * Valid user. Update touch info
         */
        $q = "UPDATE active_users SET last_touch_time = now() WHERE user_id = $user_id ";
        mysql_query($q);
        
        /*
         * Every audit runs this function, which will clean any inactive
         * accounts from the active_users table
         */
        pruneInactiveUsers();
        
        /*
         * Now we check if this room is a pay-for-access room. Simply,
         * charge the bill_per_minute, which may be zero(0).
         */
        $paying = (bool)$bill_per_minute;

        if($paying)
          {
            /*
             * How many seconds since last touch?
             */
            $secs = time() - strtotime($last_touch_time);
            
            /*
             * What's the cost per second? 
             */
            $persec = $bill_per_minute/60;

            /*
             * what does the user owe (2 dec places)?
             * NOTE: this rounds up.
             */
            $owes = $secs * $persec;

            $remainingCredits = round(($credits_remaining - $owes), 2);
            
            /*
             * Does the user have the credit?
             */
            $canpay = ($remainingCredits > 0);
            
            /*
             * before deciding whether to boot the user, we first
             * charge the credits. This of course can result in 
             * negative credits.  
             */
            
            $q = "  UPDATE temp_accounts 
                    SET credits_remaining = $remainingCredits 
                    WHERE user_id = $user_id";
            $r = mysql_query($q);
            
            /*
             * TODO: do more checking for success of above
             */
            
            if($canpay === false)
              {
                /*
                 * Out of credits. Inform, boot
                 */
                echo "status=no_credits";
                exit;
              }
          }

       /*
        * if we got here, we have successfully updated user session.
        * return the ok.
        */
       
       echo "status=ok";
       exit;
      }
  }


/*
 * if we got here, the user should be booted
 */
echo "status=boot";
exit;
?>