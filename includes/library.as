Library = 
  {
    dateMonths:
      [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ],
      
    dateWeek:
      [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday'
      ],
      
    String:
      {        
        trim: function(txt_str) 
          {
          	while(txt_str.charAt(0) == " ") 
          	  {
          		  txt_str = txt_str.substring(1, txt_str.length);
          	  }
          	
          	while (txt_str.charAt(txt_str.length-1) == " ") 
          	  {
          		  txt_str = txt_str.substring(0, txt_str.length-1);
          	  }
          	  
          	return txt_str;
          },  
        
        findAndReplace: function(input, stringToFind, stringToInsert) 
          {
        	  var output = "";
        	  var len = stringToFind.length;
        	  while(input.indexOf(stringToFind) != -1) 
        	    {
        		    currOffset = input.indexOf(stringToFind);
        		    output = output+input.substring(0, currOffset);
        		    output = output+stringToInsert;
        		    input = input.substr(currOffset+len, input.length);
        	    }
        	  output = output+input;

        	  return output;
          },
          
        cleanControlCharacters: function(txt)
          {
            /*
             * lose special characters. Only accept
             * character code in range 32 - 126 (ascii)
             */
            var out = '';
            var _c = '';
            
            for(z=0; z < txt.length; z++)
              {
                _c = txt.charCodeAt(z);
                    
                if((_c >= 32) && (_c <= 126))
                  {
                    out += txt.charAt(z);
                  }
              }
            
            return out;
          }
      },
      
    Services:
      {        
        call: function(args)
          {
            switch(args[0])
              {
                case 'audit':
                  
                  var s     = new LoadVars();
	                //s.test    = "test";
	                s.onLoad  = Library.Services.catchAuditResult;
	                
	                s.load('services/audit.php?username=' + Config.nick + '&challenge=' + Config.token + '&room=' + Config.currentRoomName());
                  
                break;
                
                default:
                break;
              }
          },
          
        catchAuditResult: function(resp)
          {
            if(resp)
              {
                switch(this['status'])
                  {
                    case 'ok':
                    
                    break;

                    case 'no_credits':
                
                      View.Screen.writeWarning("OUT_OF_CREDITS");
                      User.boot();
                  
                    break;
                
                    case 'boot':
                    
                      View.Screen.writeWarning("GENERAL_BOOT");
                      User.boot();
                    
                    break;
                    
                    default:
                      View.Screen.write(this['status']);
                    break;
                  }
              }
            /*
             * Getting here means we have either not received a response,
             * or have been given a failure report from the audit. In either
             * case, the user gets booted.  If there is a failure notice
             * sent, show it to the user, then boot.
             */
          }
      }
  }

