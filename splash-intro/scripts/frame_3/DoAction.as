function ghostIn(z, s)
{
   ziel = z;
   dispMapImage = new flash.display.BitmapData(z._width,z._height);
   dispMapImage.perlinNoise(z._width,z._height,10,nuss4,false,true,1,true);
}
function mische(startScale, endScale, startAlpha, endAlpha, speed)
{
   var obj = this;
   var _loc2_ = new mx.effects.Tween(ziel,[startScale,startAlpha],[endScale,endAlpha],speed);
   ziel.onTweenUpdate = function(a)
   {
      dispMapFilter = new flash.filters.DisplacementMapFilter(obj.dispMapImage,new flash.geom.Point(0,0),1,1,a[0],a[0],"color");
      obj.ziel.filters = [dispMapFilter];
      obj.ziel._alpha = a[1];
   };
   ziel.onTweenEnd = function()
   {
      obj.onComplete();
   };
}
ghostIn(image,100);
mische(1000,0,0,100,1500);
