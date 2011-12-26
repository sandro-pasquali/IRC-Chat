/************************************************
 *                                              *
 * 					IRCConnector Class                  *
 *                                              *
 ************************************************
 

 ************************************************/
 
function IRCConnectorClass()
  {
    this.connection = new XMLSocket();
    
    this.connect = function(host,port)
      {
      trace(host + port);
        XMLSocket.prototype.onData = IRCReceiver.parseReceipt;
        
        this.connection.connect(host,port);
      };
      
    this.close = function()
      {
        this.connection.close();
      };

    this.connection.onConnect = function(success)
      {
      	if(success)
      	  {
        		View.Screen.write("<b>Server connection established!</b>");
        		IRCSender.prepareAndSend("PASS " + Config.password);
        		IRCSender.prepareAndSend("NICK " + Config.nick);
        		IRCSender.prepareAndSend("USER " + Config.user + " 0 * :" + Config.realName);
        		
        		IRCSender.prepareAndSend("JOIN " + Config.startRoom);
        		
        		//IRCSender.prepareAndSend("OPER sandro pandro");
        		
        		//IRCSender.prepareAndSend("LIST");
      	  }
      	else
      		{
      		  View.Screen.write("<b>Server connection failed!</b>");
      		}
      };
      
    this.connection.onClose = function()
      {
      	View.Screen.write("<b>Server connection lost</b>");
      };
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
/************************************************
 *                                              *
 * 					IRCReciever Class                   *
 *                                              *
 ************************************************
 

 ************************************************/
 
 
function IRCReceiverClass()
  {
    this.getUserFromReceipt = function(c)
      {
        var _n = c.split('!');
        
        return _n[0].substr(1); 
      };
      
    this.parseReceipt = function(d)
      {  
        //View.Screen.write(d);
      
        rData = Library.String.trim(d);

      	/*
      	 * split command string on space
      	 */
      	var commands = rData.split(chr(32));
      	
      	var c0 = Library.String.cleanControlCharacters(commands[0]);
      	var c1 = Library.String.cleanControlCharacters(commands[1]);
      	var c2 = Library.String.cleanControlCharacters(commands[2]);
      	var c3 = Library.String.cleanControlCharacters(commands[3]);
      	
      	/*
      	 * First check if c0 is a direct IRC command.
      	 * We know it is does not begin with ':'
      	 */
      	if(c0.charAt(0) != ':')
      	  {
      	    switch(c0)
      	      {
                case 'PING':
                
                  IRCSender.PONG();
                  
                break;

                default:
                
                  //View.Screen.write('unknown c0: ' + Library.String.trim(rData));
                
                break;
              }
      	  }
      	else 
          {
            /*
             * :sandro!~theClient@escomchat1.webair.com JOIN :#lobby
             */
            if(c1 == 'JOIN')
              {
                var n = IRCReceiver.getUserFromReceipt(c0);
                
                View.Screen.writeSystemMsg(n + ' has joined the ' + Config.currentRoomName());  
                
                IRCSender.NAMES();
              }
              
            else if((c1 == 'QUIT') || (c1 == 'PART'))
              {
                var n = IRCReceiver.getUserFromReceipt(c0);
                
                View.Screen.writeSystemMsg(n + ' has left');  
                
                IRCSender.NAMES();
              }
              
            else if(c1 == 'PRIVMSG')
              {
                var n = IRCReceiver.getUserFromReceipt(c0);
                
                /*
                 * The user doesn't see ANY messages from
                 * users on his/her ignore list
                 */
                if(User.isignoring(n))
                  {
                    return;
                  }
                
                /* 
                 * going to assume that every item after c3 in commands[]
                 * will be a word; concatenate.
                 */

                var msg = '';
                
                for(s=3; s < commands.length; s++)
                  {
                    msg += commands[s] + ' ';  
                  }

                var f_msg = Library.String.cleanControlCharacters(msg.substr(1));
                
                /*
                 * Message is either private or public;
                 * it is public if c2 == Config.startRoom
                 */
                if(c2 == Config.currentRoom)
                  {
                    /*
                     * write public message to screen
                     */
                    
                    View.Screen.write('&lt;' + n + '&gt; ' + f_msg);
                  }
                else 
                  {
                    /*
                     * write private message to screen
                     */
                    View.Screen.write('<img src="images/icons/hearts.jpg" align="left" width="12" height="12" hspace="0" vspace="0" /><font color="#FF80FF">From ' + n + ': ' + f_msg + '</font>');
                  }
              }  
            
            /*
             * fired on successful initial connect
             */
      	    else if(c1 == "001")
              {  
                View.Screen.writeGroup(_.login);
      		    }
            
            /*
             * list of users in room
             */
      	    else if(c1 == "353")
              {  
                View.refreshUserList(rData);
      		    }
      		    
            /*
             * nickname already in use.
             */
      	    else if(c1 == "433")
              {  
                var m = '';
                
                View.Screen.writeWarning('JOIN_WITH_EXISTING_NICK');
                
                IRCSender.prepareAndSend("ISON Config.nick");
      		    }
      		    
      		  else
      		    {
      		      View.Screen.write('unknown: ' + rData);
      		    }
          }
      }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
/************************************************
 *                                              *
 * 					IRC Sender Class                    *
 *                                              *
 ************************************************
 
 
 ************************************************/
 
function IRCSenderClass()
  {
    this.PONG = function()
      {
        IRCSender.prepareAndSend("PONG " + ':' + Config.uri);
      }
    
    /*
     * Request a new list of room member names; processed
     * and user list updated by IRCReceiver
     */
    this.NAMES = function()
      {
        IRCSender.prepareAndSend("NAMES " + Config.currentRoom);
      }
      
    this.prepareAndSend = function(d)
      {
        IRCConnector.connection.send(d + "\r\n");
      }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
/************************************************
 *                                              *
 * 					     User Class                     *
 *                                              *
 ************************************************
 

 ************************************************/
  
function UserClass()
  {
    this._ignoreList  = [];
    
    this.boot = function()
      {
        IRCConnector.close();
      };
    
    this.ignore = function(nm)
      {
        /*
         * check if already ignored
         */
        if(this.isignoring(nm))
          {
            View.Screen.writeSystemMsg("You are already ignoring > " + nm);
            return;
          }

        /*
         * check if a live user, add
         */
        if(View.userExists(nm))
          {
            this._ignoreList.push(nm);
            View.Screen.writeSystemMsg("You are now ignoring > " + nm);
          }
        else
          {
            View.Screen.writeSystemMsg("I don't know who `" + nm + "` is");
          }
      };
      
    this.unignore = function(nm)
      {
        for(p in this._ignoreList)
          {
            if(this._ignoreList[p] == nm)
              {
                this._ignoreList.splice(p,1);
                View.Screen.writeSystemMsg("You are no longer ignoring > " + nm);
                return;
              }
          }
          
        View.Screen.writeSystemMsg("You are not ignoring > " + nm);
      };
      
    this.isignoring = function(nm)
      {
        for(p in this._ignoreList)
          {
            if(this._ignoreList[p] == nm)
              {
                return true;
              }
          }
  
        return false;
      }; 
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
/************************************************
 *                                              *
 * 					View Class                          *
 *                                              *
 ************************************************
 

 ************************************************/
  
  
function ViewClass()
  {
    this._currentUserList   = [];
    this._globalIn          = '';
    
    this.clearUserList = function()
      {
        this._currentUserList = [];
        userList.htmlText = '';
      }
      
    this.getUserList = function()
      {
        return this._currentUserList;
      }
    
    this.getCompletedName = function(frag)
      {
        if(this._currentUserList[frag])
          {
            return this._currentUserList[frag];
          }
        
        return frag;
      };

    this.refreshUserList = function(d)
      {
        /*
         * user list; re-split on ':'; last index == list
         *
         * :chat.url.com 353 sandro = #lobby :sandro username 
         */
        var _n = d.split(':');
        var _l = _n[_n.length-1].split(' ');
        
        var nl = '';
        
        this.clearUserList();
        
        for(n=0; n < (_l.length-1); n++)
          {
            var ref = '<a href="asfunction:_root.testing,' + _l[n] + '">' + _l[n] + '</a>';
            if(_l[n] == Config.nick)
              {
                nl += '<p align="left" class="operator_username"><span class="user_sex">*</span> ' + ref + '</p>';
              }
            else
              {
                nl += '<p align="left" class="username"><span class="user_sex">*</span> ' + ref + '</p>';
              }
            
            this._currentUserList.push(_l[n]);
          }
        
        userList.htmlText = nl;
      };
      
    this.userExists = function(name)
      {
        var ul = this.getUserList();
        for(p in ul)
          {
            if(ul[p] == name)
              {
            	  return true;
            	}
          }
          
        return false;
      };

    this.storeGlobalInput = function()
      {
        this._globalIn = GlobalInputClip.inputMsg.htmlText;
      };
      
    this.clearGlobalInput = function()
      {
        this.setGlobalInput('');
      };
      
    this.getGlobalInput = function()
      {
        return GlobalInputClip.inputMsg.htmlText;
      };
      
    this.setGlobalInput = function(str)
      {
        GlobalInputClip.inputMsg.htmlText = str;
        this.storeGlobalInput();
      };
      
    this.clearScreen = function()
      {
        msgArea.htmlText = '';
      };
      
    this.showDate = function()
      {
        var d = new Date(); 
        
        var mn = Library.dateMonths[d.getMonth()];
        var wk = Library.dateWeek[d.getDay()];
        var yr = d.getFullYear();
        var dt = d.getDate();
        var hr = d.getHours();
        var mi = d.getMinutes();
        
        View.Screen.write('<img src="images/icons/time.jpg" width="12" height="12" border="0" vspace="0" hspace="0" /><font color="#FF8000"><b> ' + mn + ' ' + dt + ', ' + yr + ' ' + hr + ':' + mi + '</b></font>');
      };
      
    /*****************************************
     *              View.Screen              *
     *                                       *
     *****************************************/
     
    this.Screen = 
      {        
        write: function(txt)
          {
            var t = Library.String.trim(txt);
            
            /*
             * It is possible that as chat continues, the text buffer
             * will grow large enough to hit performance. So we do a simple
             * truncation, to keep the length roughly equal to a set # of bytes.
             * We have a lot of play, so any reasonably high number should
             * be fine. Around 3 or 4 screens saved should do it. 
             * NOTE: since this is html text, the truncation is likely to break
             * an html tag. So we trim the resulting string at next '</p>'.
             */
            var m = msgArea.htmlText;
            
            if(m.length > Config.screenBufferLength)
              {
                m = m.substring(m.length-Config.screenBufferLength,m.length);
                var s = m.indexOf('</p>') || 0;
                m = m.substring(s,m.length);
              }
              
            msgArea.htmlText = m + '<p align="left">' + t + '</p>';
            
            msgArea.scroll += 10;
          },
        
        writeGroup: function(sub)
          {
            out = '<span class="system_group">';
            out += _.header;

            for(r = 0; r < sub.length; r++)
              {
                out += _.cursor + '<b>' + sub[r] + '</b>' + _.brk;
              }
                  
            out += _.footer;
            out += '</span>';
                
            View.Screen.write(out);
          },
          
        writeSystemMsg: function(sm)
          {
            var out = '<span class="system_message"><img src="images/icons/star.jpg" align="left" width="12" height="12" hspace="0" vspace="0" /> ' + sm + '</span>';
          
            View.Screen.write(out);
          },
          
        writeWarning: function(sm)
          {
            if(_.warnings[sm])
              {
                var out = '<span class="system_warning"><img src="images/icons/warning.jpg" align="left" width="12" height="12" hspace="0" vspace="0" /> ' + _.warnings[sm] + '</span>';
            
                View.Screen.write(out);
              }
          },
          
        showHelp: function(sub)
          {
            /*
             * user is able to send either an argument (identifying
             * a sub-help file), or no argument, indicating basic help file
             */
            if(sub && _.help[sub])
              {
                this.writeGroup(_.help[sub]);
              }
            else
              {
                /*
                 * write all help
                 */
                for(h in _.help)
                  {
                    this.writeGroup(_.help[h]);
                  }
              }
          }
      };
  }
  













/************************************************
 *                                              *
 * 					Control Methods                     *
 *                                              *
 ************************************************
 
 These are called by various interface controls.
 
 ************************************************/
 
function __handleUserInput()
{
  var userIn = Library.String.trim(GlobalInputClip.inputMsg.htmlText);
  
  if(userIn.length > 0)
    {
      /*
       * There are two types of inputs: a command, or straight talk.
       * Split the string on spaces, and see if a[0] is a command.
       * If so, do special treatment; if not, just dump text
       */
       
      var s     = userIn.split(' ');
      var out   = '';
      
      /*
       * NOTE: we're shifting the command array here;
       * Just wanted to catch your attention.
       */
      var cmd   = s.shift();
      
      if(cmd.charAt(0) == '/')
        {
          switch(cmd)
            {
              case '/clear':
              case '/c':
                  
                View.clearScreen();
                  
              break;
              
              case '/time':
              case '/t':
              case '/date':
              case '/d':
                  
                View.showDate();
                  
              break;
              
              case '/help':
              case '/h':
                
                View.Screen.showHelp(s[0] || false);

              break;
              
              case '/broadcast':
              case '/b':

                /*
                 * Sends subsequent text to broadcast movie
                 */
                Config.localCon.send("__BROADCASTER__","receiver",s.join(' '));
              
              break;
              
              case '/ignore':
              case '/i':
              
                if(s[0])
                  {
                    User.ignore(s[0]);
                  }
                else
                  {
                    View.Screen.writeSystemMsg('You have not given a name to ignore');
                  }
                  
              break;
              
              case '/unignore':
              case '/ui':
              
                if(s[0])
                  {
                    User.unignore(s[0]);
                  }
                else
                  {
                    View.Screen.writeSystemMsg('You have not given a name to unignore');
                  }
                  
              break;
              
              case '/msg':
              case '/m':
                             
                /*
                 * Expects arg[1]; TODO: check for +1 arg commands
                 */
                var name = s.shift();
                
                /*
                 * Cannot write to anyone on your ignore list
                 */
                if(!User.isignoring(name))
                  {
                    /*
                     * Expects name to be a current user name; check and execute
                     */
                    var ul = View.getUserList();
                    
                    if(View.userExists(name))
                      {
                        /*
                         * Ok, to a valid user. join the segments of input, send, exit
                         */
                        var snd = s.join(' ');
                        
                        if(snd != '')
                          {
                            IRCSender.prepareAndSend("PRIVMSG " + name + " :" + snd);
                            out = '<font color="#ff0000">&lt;Private:' + name + '&gt;</font> ' + snd;
                            
                            View.Screen.write(out);
                          }
                        else
                          {
                            View.Screen.writeSystemMsg('Nothing sent: no message given. Format -> /msg nickname message');
                          }
                      }
                    else
                      {
                        View.Screen.writeSystemMsg('Command not understood >> ' + cmd + ' >> nickname not found. No message sent.');
                      }
                  }
                else
                  {
                    View.Screen.writeSystemMsg('You cannot send messages to people you are ignoring.');
                  }
                  
              break;
              
              default:
              
                View.Screen.writeSystemMsg('Command not understood >> ' + cmd);
              
              break;
            }
        }
      else
        {
          /*
           * No command: just dump text
           */
          out = '<font color="#ff0000">&lt;me&gt;</font> ' + userIn;

          IRCSender.prepareAndSend("PRIVMSG " + Config.currentRoom + " :" + userIn);
          
          View.Screen.write(out);
        }
        
      View.clearGlobalInput();   
    }
}







function testing(arg)
  {
    View.Screen.write('<font color="#ff0000">&lt;$clickedon&gt;</font> ' + arg);
  }