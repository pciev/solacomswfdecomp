var listenerObject = new Object();
listenerObject.complete = function(eventObject)
{
   myPlayback4.play();
   if(_root.soundIsOn)
   {
      _root.fadeBGMusic(0);
   }
};
myPlayback4.addEventListener("complete",listenerObject);
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
myPlayback4.addEventListener("paused",listenerObject);
myPlayback4.addEventListener("stateChange",listenerObject);
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
myPlayback4.addEventListener("playing",listenerObject);
myPlayback4.addEventListener("stateChange",listenerObject);
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
myPlayback4.addEventListener("scrubStart",listenerObject);
myPlayback4.addEventListener("stateChange",listenerObject);
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
myPlayback4.addEventListener("scrubFinish",listenerObject);
myPlayback4.addEventListener("stateChange",listenerObject);
