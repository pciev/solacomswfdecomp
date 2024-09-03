stop();
this.onEnterFrame = function()
{
   if(rewind == true)
   {
      prevFrame();
   }
};
this.onRollOver = function()
{
   rewind = false;
   play();
};
this.onRollOut = function()
{
   rewind = true;
};
