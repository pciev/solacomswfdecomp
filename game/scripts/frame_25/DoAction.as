var listenerObject = new Object();
listenerObject.complete = function(eventObject)
{
   myPlayback1.play();
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(0);
   }
};
myPlayback1.addEventListener("complete",listenerObject);
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
myPlayback1.addEventListener("paused",listenerObject);
myPlayback1.addEventListener("stateChange",listenerObject);
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
myPlayback1.addEventListener("playing",listenerObject);
myPlayback1.addEventListener("stateChange",listenerObject);
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
myPlayback1.addEventListener("scrubStart",listenerObject);
myPlayback1.addEventListener("stateChange",listenerObject);
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
myPlayback1.addEventListener("scrubFinish",listenerObject);
myPlayback1.addEventListener("stateChange",listenerObject);
