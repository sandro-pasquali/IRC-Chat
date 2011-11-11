/*****************************************
 *                                       *
 *            `temp_accounts`            *
 *                                       *
 *****************************************/
 
DROP TABLE IF EXISTS `temp_accounts`;
CREATE TABLE temp_accounts (
  user_id int(12) NOT NULL auto_increment,
  username varchar(32) NOT NULL default '',
  is_performer tinyint(1) NOT NULL default 0,
  credits_remaining int(12) default '0',
  cost_per_minute int(3) default '1',
  bill_per_minute int(3) default '1',
  last_buy_date datetime NOT NULL default '0000-00-00 00:00:00',
  last_bill_date datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (user_id),
  KEY credits_remaining (credits_remaining),
  KEY cost_per_minute (cost_per_minute),
  KEY bill_per_minute (bill_per_minute),
  KEY last_buy_date (last_buy_date),
  KEY last_bill_date (last_bill_date)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Temporary demo accounts table: eventually tie to a real account table';

LOCK TABLES `temp_accounts` WRITE;
INSERT INTO `temp_accounts` VALUES (1,'user1',0,1000,1,0,now(),now()),(2,'user2',0,1000,1,0,now(),now()),(3,'user3',0,1000,1,0,now(),now()),(4,'performer1',1,0,0,1,now(),now()),(5,'performer2',1,0,0,1,now(),now());
UNLOCK TABLES;


/*****************************************
 *                                       *
 *             `active_users`            *
 *                                       *
 *****************************************/
 
DROP TABLE IF EXISTS `active_users`;
CREATE TABLE active_users (
  user_id int(12) NOT NULL default '0',
  username varchar(32) NOT NULL default '',
  private_key varchar(32) NOT NULL default '',
  challenge varchar(40) NOT NULL default '',
  room varchar(64) NOT NULL default '',
  room_join_time datetime NOT NULL default '0000-00-00 00:00:00',
  last_touch_time datetime NOT NULL default '0000-00-00 00:00:00',
  is_performer tinyint(1) NOT NULL default 0,
  credits_remaining int(12) default '0',
  cost_per_minute int(3) default '1',
  bill_per_minute int(3) default '1',
  last_buy_date datetime NOT NULL default '0000-00-00 00:00:00',
  last_bill_date datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (user_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Users currently active in the chat';

/*****************************************
 *                                       *
 *                 `audit`               *
 *                                       *
 *****************************************/
 
DROP TABLE IF EXISTS `audit`;
CREATE TABLE audit (
  id int(12) NOT NULL auto_increment,
  username varchar(32) NOT NULL default '',
  user_id int(12) NOT NULL default '0',
  challenge varchar(40) NOT NULL default '',
  room varchar(64) NOT NULL default '',
  room_join_time datetime NOT NULL default '0000-00-00 00:00:00',
  last_touch_time datetime NOT NULL default '0000-00-00 00:00:00',
  is_performer tinyint(1) NOT NULL default 0,
  credits_remaining int(12) default '0',
  cost_per_minute int(3) default '1',
  bill_per_minute int(3) default '1',
  last_buy_date datetime NOT NULL default '0000-00-00 00:00:00',
  last_bill_date datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (id),
  KEY user_id (user_id),
  KEY username (username),
  KEY room_join_time (room_join_time),
  KEY last_touch_time (last_touch_time),
  KEY room (room),
  KEY credits_remaining (credits_remaining),
  KEY cost_per_minute (cost_per_minute),
  KEY bill_per_minute (bill_per_minute),
  KEY last_buy_date (last_buy_date),
  KEY last_bill_date (last_bill_date)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Audit trail';


