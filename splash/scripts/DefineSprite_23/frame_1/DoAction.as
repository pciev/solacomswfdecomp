trysound = new Sound(this);
trysound.attachSound("sound1");
this.onRollOver = function()
{
   this.over = true;
   flashIt.gotoAndPlay(2);
};
this.onRollOut = this.onDragOut = function()
{
   this.over = false;
};
this.onEnterFrame = function()
{
   if(over)
   {
      this.nextFrame();
   }
   else
   {
      this.prevFrame();
   }
};
this.onPress = function()
{
   trysound.start(0,1);
   _parent.gotoAndPlay("fadeout-shep");
};
stop();
