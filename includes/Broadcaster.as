
/*
 * local user cam
 */

var cam = Camera.get();
var mic = Microphone.get();

mic.setRate(8);
mic.setUseEchoSuppression(1); 
mic.setSilenceLevel(8); 
mic.setGain(30); 
        
cam.setMode(320, 240, 3,true)
cam.setQuality(0, 83);
cam.setKeyFrameInterval(15);
        
remoteVideo.attachVideo(cam); 

/*
 * General functionality
 */

function BroadcasterClass()
  {
    this.Display = 
      {
        write: function(txt,append)
          {
            var t = txt || '';
            var a = append || false;
            
            t = (t) ? '<p align="left">' + txt + '</p>' : ''; 
            
            if(a)
              {
                stdout.htmlText += '<p align="left">' + t + '</p>'; 
              } 
            else
              {
                stdout.htmlText = '<p align="left">' + t + '</p>'; 
              }
          }
      };
  }

var Broadcaster = new BroadcasterClass();
