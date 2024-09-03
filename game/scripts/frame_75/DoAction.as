var listenerObject = new Object();
listenerObject.complete = function(eventObject)
{
   myPlayback3.play();
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(0);
   }
};
myPlayback3.addEventListener("complete",listenerObject);
var listenerObject = new Object();
listenerObject.paused = function(eventObject)
{
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(100);
   }
};
listenerObject.stateChange = function(eventObject)
{
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(100);
   }
};
myPlayback3.addEventListener("paused",listenerObject);
myPlayback3.addEventListener("stateChange",listenerObject);
var listenerObject = new Object();
listenerObject.playing = function(eventObject)
{
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(0);
   }
};
listenerObject.stateChange = function(eventObject)
{
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(0);
   }
};
myPlayback3.addEventListener("playing",listenerObject);
myPlayback3.addEventListener("stateChange",listenerObject);
var listenerObject = new Object();
listenerObject.scrubStart = function(eventObject)
{
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(0);
   }
};
listenerObject.stateChange = function(eventObject)
{
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(0);
   }
};
myPlayback3.addEventListener("scrubStart",listenerObject);
myPlayback3.addEventListener("stateChange",listenerObject);
var listenerObject = new Object();
listenerObject.scrubFinish = function(eventObject)
{
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(0);
   }
};
listenerObject.stateChange = function(eventObject)
{
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(0);
   }
};
myPlayback3.addEventListener("scrubFinish",listenerObject);
myPlayback3.addEventListener("stateChange",listenerObject);
