/************************************************
 *                                              *
 * 					GlobalInputClip actions             *
 *                                              *
 ************************************************/
 
onClipEvent(load)
  {
    inputMsg.backgroundColor = 0xFFFFF0;
  }
  
onClipEvent(keyDown) 
	{
    if(Selection.getFocus().indexOf('GlobalInputClip.inputMsg') != -1)
      {    
    	  if(Key.isDown(Key.ENTER)) 
    	    {
    		    _root.__handleUserInput();
    		  }
       
    		else if(Key.isDown(Key.UP)) 
    		  {		
    		     trace(blah);
    	    } 
    	    
    	  else if(Key.isDown(Key.DOWN)) 
    	    {
            //trace('down');
    	    } 
    	    
    	  else if(Key.isDown(Key.RIGHT))
    	    {
    	      /*
    	       * want to autocomplete on right arrow, a la unix, against userList
    	       */
    	      
    	      var curIn   = _root.View.getGlobalInput();
    	      var cur     = curIn.split(' ');
    	      var node    = cur.pop();
    	      var hc, uA;

    	      uA = _root.View.getUserList();
    	      hc = [];
    	          
    	      for(p in uA)
    	        {
    	          if(uA[p].substr(0,node.length) == node)
    	            {
    	              hc.push(uA[p]);
    	            }
    	        }
    	      
    	      /*
    	       * Only one hit. use that
    	       */
    	      if(hc.length == 1)
    	        {
    	          /*
    	           * Normally we join the input array + space + changed last node.
    	           * If this is the first word, we don't have an array, or
    	           * the need for a space. Do some formatting checks, and update box.
    	           */
    	          var pref = (cur.length > 0) ? cur.join(' ') + ' ' : ''; 
    	          _root.View.setGlobalInput(pref + hc[0]); 
    	        }

    	        
    	      _root.View.storeGlobalInput();
    	      
    	      /*
    	       * moves cursor to end of input. better way?
    	       */
    	      Selection.setSelection(curIn.length + 50,curIn.length + 100);
    	    }
    	}
	}
