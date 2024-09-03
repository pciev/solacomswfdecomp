function startPreload()
{
   preloader_mc.gotoAndPlay("start");
}
function animateIn()
{
   preloader_mc.stop();
   preloader_mc.onEnterFrame = this.checkLoaded;
}
function checkLoaded()
{
   var _loc4_ = getBytesLoaded();
   var _loc3_ = getBytesTotal();
   var _loc5_ = _loc4_ / _loc3_;
   var _loc2_ = preloader_mc.loader_mc._currentframe;
   var _loc1_ = preloader_mc.loader_mc._totalframes;
   var _loc6_ = Math.ceil(_loc1_ * _loc5_);
   if(_loc6_ > _loc2_)
   {
      preloader_mc.loader_mc.play();
   }
   else
   {
      preloader_mc.loader_mc.stop();
   }
   preloader_mc.pct_str = Math.round(_loc2_ / _loc1_ * 100).toString();
   if(_loc3_ > 20 && _loc4_ == _loc3_ && _loc2_ == _loc1_ && preloader_mc.loader_mc)
   {
      preloadComplete();
   }
}
function preloadComplete()
{
   preloader_mc.onEnterFrame = null;
   preloader_mc.gotoAndPlay("finish");
}
function animateOut()
{
   preloader_mc.stop();
   loadComplete();
}
function loadComplete()
{
   preloader_mc.removeEventListener("loadComplete",this);
   gotoAndStop("build");
   play();
}
var pct_str;
preloader_mc.addEventListener("loadComplete",this);
var menu_cm = new ContextMenu();
menu_cm.hideBuiltInItems();
this.menu = menu_cm;
stop();
startPreload();
