function createClouds()
{
   function moveClouds()
   {
      if(this.vz > - depthOfField)
      {
         this.vz -= moveSpeed;
         if(this._alpha < 100)
         {
            this._alpha += cloudFadeInSpeed;
         }
      }
      else
      {
         var _loc3_ = Math.ceil(Math.random() * cloud._totalframes);
         this.gotoAndStop(_loc3_);
         this.vz = cloudsStartingFar + (Math.random() * 100 - 50);
         this.vx = Math.random() * (cloudsAppearAreaWidth * 2) - cloudsAppearAreaWidth;
         this._alpha = 0;
      }
      var _loc2_ = depthOfField / (depthOfField + this.vz);
      this._xscale = this._yscale = _loc2_ * 100;
      this._x = vpX + this.vx * _loc2_;
      this._y = vpY + this.vy * _loc2_;
      this.swapDepths(- this.vz);
   }
   var _loc7_ = 715;
   var _loc9_ = 330;
   var _loc12_ = 1;
   var _loc4_ = 25;
   var depthOfField = 350;
   var moveSpeed = 2;
   var _loc5_ = 75;
   var cloudsAppearAreaWidth = 700;
   var cloudsStartingFar = 300;
   var cloudFadeInSpeed = 5;
   var _loc13_ = 0;
   skyColorsMC.gotoAndStop(_loc12_);
   skyColorsMC._width = _loc7_;
   skyColorsMC._height = _loc9_;
   var vpX = _loc7_ / 2;
   var vpY = _loc9_ / 2 + _loc13_;
   var _loc3_ = this.createEmptyMovieClip("cloudsHolder",1);
   var _loc6_ = this.createEmptyMovieClip("Mask",2);
   var _loc11_ = _loc7_;
   var _loc10_ = _loc9_;
   _loc6_.beginFill(65280,100);
   _loc6_.lineTo(_loc11_,0);
   _loc6_.lineTo(_loc11_,_loc10_);
   _loc6_.lineTo(0,_loc10_);
   _loc6_.lineTo(0,0);
   _loc3_.setMask(_loc6_);
   var _loc2_ = 0;
   while(_loc2_ < _loc4_)
   {
      var cloud = _loc3_.attachMovie("cloud","cloud" + _loc2_,_loc2_);
      var _loc14_ = Math.ceil(Math.random() * cloud._totalframes);
      cloud.gotoAndStop(_loc14_);
      cloud.vx = Math.random() * (cloudsAppearAreaWidth * 2) - cloudsAppearAreaWidth;
      cloud.vy = _loc5_;
      cloud.vz = Math.random() * (cloudsStartingFar * 2) - cloudsStartingFar;
      cloud.onEnterFrame = moveClouds;
      _loc2_ = _loc2_ + 1;
   }
}
createClouds();
