var listenerObject = new Object();
listenerObject.complete = function(eventObject)
{
   myPlayback5.play();
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(0);
   }
};
myPlayback5.addEventListener("complete",listenerObject);
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
myPlayback5.addEventListener("paused",listenerObject);
myPlayback5.addEventListener("stateChange",listenerObject);
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
myPlayback5.addEventListener("playing",listenerObject);
myPlayback5.addEventListener("stateChange",listenerObject);
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
myPlayback5.addEventListener("scrubStart",listenerObject);
myPlayback5.addEventListener("stateChange",listenerObject);
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
myPlayback5.addEventListener("scrubFinish",listenerObject);
myPlayback5.addEventListener("stateChange",listenerObject);
