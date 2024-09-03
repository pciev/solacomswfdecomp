var listenerObject = new Object();
listenerObject.complete = function(eventObject)
{
   myPlayback6.play();
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(0);
   }
};
myPlayback6.addEventListener("complete",listenerObject);
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
myPlayback6.addEventListener("paused",listenerObject);
myPlayback6.addEventListener("stateChange",listenerObject);
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
myPlayback6.addEventListener("playing",listenerObject);
myPlayback6.addEventListener("stateChange",listenerObject);
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
myPlayback6.addEventListener("scrubStart",listenerObject);
myPlayback6.addEventListener("stateChange",listenerObject);
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
myPlayback6.addEventListener("scrubFinish",listenerObject);
myPlayback6.addEventListener("stateChange",listenerObject);
