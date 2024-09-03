class mx.video.CuePointManager
{
   var _owner;
   var _id;
   var _asCuePointTolerance;
   var _linearSearchTolerance;
   var _metadataLoaded;
   var allCuePoints;
   var asCuePoints;
   var _disabledCuePoints;
   var flvCuePoints;
   var navCuePoints;
   var eventCuePoints;
   var _asCuePointIndex;
   var _disabledCuePointsByNameOnly;
   static var DEFAULT_LINEAR_SEARCH_TOLERANCE = 50;
   static var cuePointsReplace = ["&quot;","\"","&#39;","\'","&#44;",",","&amp;","&"];
   function CuePointManager(owner, id)
   {
      this._owner = owner;
      this._id = id;
      this.reset();
      this._asCuePointTolerance = this._owner.getVideoPlayer(this._id).playheadUpdateInterval / 2000;
      this._linearSearchTolerance = mx.video.CuePointManager.DEFAULT_LINEAR_SEARCH_TOLERANCE;
   }
   function reset()
   {
      this._metadataLoaded = false;
      this.allCuePoints = null;
      this.asCuePoints = null;
      this._disabledCuePoints = null;
      this.flvCuePoints = null;
      this.navCuePoints = null;
      this.eventCuePoints = null;
      this._asCuePointIndex = 0;
   }
   function get metadataLoaded()
   {
      return this._metadataLoaded;
   }
   function set playheadUpdateInterval(aTime)
   {
      this._asCuePointTolerance = aTime / 2000;
   }
   function get id()
   {
      return this._id;
   }
   function addASCuePoint(timeOrCuePoint, name, parameters)
   {
      var _loc3_ = undefined;
      if(typeof timeOrCuePoint == "object")
      {
         _loc3_ = mx.video.CuePointManager.deepCopyObject(timeOrCuePoint);
      }
      else
      {
         _loc3_ = {time:timeOrCuePoint,name:name,parameters:mx.video.CuePointManager.deepCopyObject(parameters)};
      }
      var _loc7_ = isNaN(_loc3_.time) || _loc3_.time < 0;
      if(_loc7_)
      {
         throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"time must be number");
      }
      var _loc6_ = _loc3_.name == null;
      if(_loc6_)
      {
         throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"name cannot be undefined or null");
      }
      var _loc2_ = undefined;
      _loc3_.type = "actionscript";
      if(this.asCuePoints == null || this.asCuePoints.length < 1)
      {
         _loc2_ = 0;
         this.asCuePoints = new Array();
         this.asCuePoints.push(_loc3_);
      }
      else
      {
         _loc2_ = this.getCuePointIndex(this.asCuePoints,true,_loc3_.time);
         _loc2_ = this.asCuePoints[_loc2_].time <= _loc3_.time ? _loc2_ + 1 : 0;
         this.asCuePoints.splice(_loc2_,0,_loc3_);
      }
      if(this.allCuePoints == null || this.allCuePoints.length < 1)
      {
         _loc2_ = 0;
         this.allCuePoints = new Array();
         this.allCuePoints.push(_loc3_);
      }
      else
      {
         _loc2_ = this.getCuePointIndex(this.allCuePoints,true,_loc3_.time);
         _loc2_ = this.allCuePoints[_loc2_].time <= _loc3_.time ? _loc2_ + 1 : 0;
         this.allCuePoints.splice(_loc2_,0,_loc3_);
      }
      var _loc5_ = this._owner.getVideoPlayer(this._id).playheadTime;
      if(_loc5_ > 0)
      {
         if(this._asCuePointIndex == _loc2_)
         {
            if(_loc5_ > this.asCuePoints[_loc2_].time)
            {
               this._asCuePointIndex = this._asCuePointIndex + 1;
            }
         }
         else if(this._asCuePointIndex > _loc2_)
         {
            this._asCuePointIndex = this._asCuePointIndex + 1;
         }
      }
      else
      {
         this._asCuePointIndex = 0;
      }
      var _loc4_ = mx.video.CuePointManager.deepCopyObject(this.asCuePoints[_loc2_]);
      _loc4_.array = this.asCuePoints;
      _loc4_.index = _loc2_;
      return _loc4_;
   }
   function removeASCuePoint(timeNameOrCuePoint)
   {
      if(this.asCuePoints == null || this.asCuePoints.length < 1)
      {
         return null;
      }
      var _loc2_ = undefined;
      switch(typeof timeNameOrCuePoint)
      {
         case "string":
            _loc2_ = {name:timeNameOrCuePoint};
            break;
         case "number":
            _loc2_ = {time:timeNameOrCuePoint};
            break;
         case "object":
            _loc2_ = timeNameOrCuePoint;
      }
      var _loc3_ = this.getCuePointIndex(this.asCuePoints,false,_loc2_.time,_loc2_.name);
      if(_loc3_ < 0)
      {
         return null;
      }
      _loc2_ = this.asCuePoints[_loc3_];
      this.asCuePoints.splice(_loc3_,1);
      _loc3_ = this.getCuePointIndex(this.allCuePoints,false,_loc2_.time,_loc2_.name);
      if(_loc3_ > 0)
      {
         this.allCuePoints.splice(_loc3_,1);
      }
      if(this._owner.getVideoPlayer(this._id).playheadTime > 0)
      {
         if(this._asCuePointIndex > _loc3_)
         {
            this._asCuePointIndex = this._asCuePointIndex - 1;
         }
      }
      else
      {
         this._asCuePointIndex = 0;
      }
      return _loc2_;
   }
   function setFLVCuePointEnabled(enabled, timeNameOrCuePoint)
   {
      var _loc4_ = undefined;
      switch(typeof timeNameOrCuePoint)
      {
         case "string":
            _loc4_ = {name:timeNameOrCuePoint};
            break;
         case "number":
            _loc4_ = {time:timeNameOrCuePoint};
            break;
         case "object":
            _loc4_ = timeNameOrCuePoint;
      }
      var _loc12_ = isNaN(_loc4_.time) || _loc4_.time < 0;
      var _loc11_ = _loc4_.name == null;
      if(_loc12_ && _loc11_)
      {
         throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"time must be number and/or name must not be undefined or null");
      }
      var _loc6_ = 0;
      var _loc2_ = undefined;
      var _loc5_ = undefined;
      if(_loc12_)
      {
         if(!this._metadataLoaded)
         {
            if(this._disabledCuePointsByNameOnly[_loc4_.name] == null)
            {
               if(!enabled)
               {
                  if(this._disabledCuePointsByNameOnly == null || this._disabledCuePointsByNameOnly.length < 0)
                  {
                     this._disabledCuePointsByNameOnly = new Object();
                  }
                  this._disabledCuePointsByNameOnly[_loc4_.name] = new Array();
               }
               this.removeCuePoints(this._disabledCuePoints,_loc4_);
               return -1;
            }
            if(enabled)
            {
               this._disabledCuePointsByNameOnly[_loc4_.name] = undefined;
            }
            return -1;
         }
         if(enabled)
         {
            _loc6_ = this.removeCuePoints(this._disabledCuePoints,_loc4_);
         }
         else
         {
            var _loc3_ = undefined;
            _loc2_ = this.getCuePointIndex(this.flvCuePoints,true,-1,_loc4_.name);
            while(_loc2_ >= 0)
            {
               _loc3_ = this.flvCuePoints[_loc2_];
               _loc5_ = this.getCuePointIndex(this._disabledCuePoints,true,_loc3_.time);
               if(_loc5_ < 0 || this._disabledCuePoints[_loc5_].time != _loc3_.time)
               {
                  this._disabledCuePoints = this.insertCuePoint(_loc5_,this._disabledCuePoints,{name:_loc3_.name,time:_loc3_.time});
                  _loc6_ += 1;
               }
               _loc2_ = this.getNextCuePointIndexWithName(_loc3_.name,this.flvCuePoints,_loc2_);
            }
         }
         return _loc6_;
      }
      _loc2_ = this.getCuePointIndex(this._disabledCuePoints,false,_loc4_.time,_loc4_.name);
      if(_loc2_ < 0)
      {
         if(enabled)
         {
            if(!this._metadataLoaded)
            {
               _loc2_ = this.getCuePointIndex(this._disabledCuePoints,false,_loc4_.time);
               if(_loc2_ < 0)
               {
                  _loc5_ = this.getCuePointIndex(this._disabledCuePointsByNameOnly[_loc4_.name],true,_loc4_.time);
                  if(mx.video.CuePointManager.cuePointCompare(_loc4_.time,null,this._disabledCuePointsByNameOnly[_loc4_.name]) != 0)
                  {
                     this._disabledCuePointsByNameOnly[_loc4_.name] = this.insertCuePoint(_loc5_,this._disabledCuePointsByNameOnly[_loc4_.name],_loc4_);
                  }
               }
               else
               {
                  this._disabledCuePoints.splice(_loc2_,1);
               }
            }
            return !this._metadataLoaded ? -1 : 0;
         }
         if(this._metadataLoaded)
         {
            _loc2_ = this.getCuePointIndex(this.flvCuePoints,false,_loc4_.time,_loc4_.name);
            if(_loc2_ < 0)
            {
               return 0;
            }
            if(_loc11_)
            {
               _loc4_.name = this.flvCuePoints[_loc2_].name;
            }
         }
         _loc5_ = this.getCuePointIndex(this._disabledCuePoints,true,_loc4_.time);
         this._disabledCuePoints = this.insertCuePoint(_loc5_,this._disabledCuePoints,_loc4_);
         _loc6_ = 1;
         return !this._metadataLoaded ? -1 : _loc6_;
      }
      if(enabled)
      {
         this._disabledCuePoints.splice(_loc2_,1);
         _loc6_ = 1;
      }
      else
      {
         _loc6_ = 0;
      }
      return !this._metadataLoaded ? -1 : _loc6_;
   }
   function removeCuePoints(cuePointArray, cuePoint)
   {
      var _loc2_ = undefined;
      var _loc4_ = undefined;
      var _loc5_ = 0;
      _loc2_ = this.getCuePointIndex(cuePointArray,true,-1,cuePoint.name);
      while(_loc2_ >= 0)
      {
         _loc4_ = cuePointArray[_loc2_];
         cuePointArray.splice(_loc2_,1);
         _loc2_ = _loc2_ - 1;
         _loc5_ = _loc5_ + 1;
         _loc2_ = this.getNextCuePointIndexWithName(_loc4_.name,cuePointArray,_loc2_);
      }
      return _loc5_;
   }
   function insertCuePoint(insertIndex, cuePointArray, cuePoint)
   {
      if(insertIndex < 0)
      {
         cuePointArray = new Array();
         cuePointArray.push(cuePoint);
      }
      else
      {
         if(cuePointArray[insertIndex].time > cuePoint.time)
         {
            insertIndex = 0;
         }
         else
         {
            insertIndex = insertIndex + 1;
         }
         cuePointArray.splice(insertIndex,0,cuePoint);
      }
      return cuePointArray;
   }
   function isFLVCuePointEnabled(timeNameOrCuePoint)
   {
      if(!this._metadataLoaded)
      {
         return true;
      }
      var _loc3_ = undefined;
      switch(typeof timeNameOrCuePoint)
      {
         case "string":
            _loc3_ = {name:timeNameOrCuePoint};
            break;
         case "number":
            _loc3_ = {time:timeNameOrCuePoint};
            break;
         case "object":
            _loc3_ = timeNameOrCuePoint;
      }
      var _loc5_ = isNaN(_loc3_.time) || _loc3_.time < 0;
      var _loc6_ = _loc3_.name == null;
      if(_loc5_ && _loc6_)
      {
         throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"time must be number and/or name must not be undefined or null");
      }
      if(_loc5_)
      {
         var _loc2_ = this.getCuePointIndex(this.flvCuePoints,true,-1,_loc3_.name);
         if(_loc2_ < 0)
         {
            return true;
         }
         while(_loc2_ >= 0)
         {
            if(this.getCuePointIndex(this._disabledCuePoints,false,this.flvCuePoints[_loc2_].time,this.flvCuePoints[_loc2_].name) < 0)
            {
               return true;
            }
            _loc2_ = this.getNextCuePointIndexWithName(_loc3_.name,this.flvCuePoints,_loc2_);
         }
         return false;
      }
      return this.getCuePointIndex(this._disabledCuePoints,false,_loc3_.time,_loc3_.name) < 0;
   }
   function dispatchASCuePoints()
   {
      var _loc5_ = this._owner.getVideoPlayer(this._id).playheadTime;
      if(this._owner.getVideoPlayer(this._id).stateResponsive && this.asCuePoints != null)
      {
         while(this._asCuePointIndex < this.asCuePoints.length && this.asCuePoints[this._asCuePointIndex].time <= _loc5_ + this._asCuePointTolerance)
         {
            this._owner.dispatchEvent({type:"cuePoint",info:mx.video.CuePointManager.deepCopyObject(this.asCuePoints[this._asCuePointIndex++]),vp:this._id});
         }
      }
   }
   function resetASCuePointIndex(time)
   {
      if(time <= 0 || this.asCuePoints == null)
      {
         this._asCuePointIndex = 0;
         return undefined;
      }
      var _loc2_ = this.getCuePointIndex(this.asCuePoints,true,time);
      this._asCuePointIndex = this.asCuePoints[_loc2_].time >= time ? _loc2_ : _loc2_ + 1;
   }
   function processFLVCuePoints(metadataCuePoints)
   {
      this._metadataLoaded = true;
      if(metadataCuePoints == null || metadataCuePoints.length < 1)
      {
         this.flvCuePoints = null;
         this.navCuePoints = null;
         this.eventCuePoints = null;
         return undefined;
      }
      this.flvCuePoints = metadataCuePoints;
      this.navCuePoints = new Array();
      this.eventCuePoints = new Array();
      var _loc5_ = undefined;
      var _loc6_ = -1;
      var _loc2_ = undefined;
      var _loc4_ = this._disabledCuePoints;
      var _loc3_ = 0;
      this._disabledCuePoints = new Array();
      var _loc9_ = 0;
      while((_loc2_ = this.flvCuePoints[_loc9_++]) != null)
      {
         if(_loc6_ > 0 && _loc6_ >= _loc2_.time)
         {
            this.flvCuePoints = null;
            this.navCuePoints = null;
            this.eventCuePoints = null;
            this._disabledCuePoints = null;
            this._disabledCuePointsByNameOnly = null;
            throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"Unsorted cuePoint found after time: " + _loc6_);
         }
         _loc6_ = _loc2_.time;
         while(_loc3_ < _loc4_.length && mx.video.CuePointManager.cuePointCompare(_loc4_[_loc3_].time,null,_loc2_) < 0)
         {
            _loc3_ = _loc3_ + 1;
         }
         if(this._disabledCuePointsByNameOnly[_loc2_.name] != null || _loc3_ < _loc4_.length && mx.video.CuePointManager.cuePointCompare(_loc4_[_loc3_].time,_loc4_[_loc3_].name,_loc2_) == 0)
         {
            this._disabledCuePoints.push({time:_loc2_.time,name:_loc2_.name});
         }
         if(_loc2_.type == "navigation")
         {
            this.navCuePoints.push(_loc2_);
         }
         else if(_loc2_.type == "event")
         {
            this.eventCuePoints.push(_loc2_);
         }
         if(this.allCuePoints == null || this.allCuePoints.length < 1)
         {
            this.allCuePoints = new Array();
            this.allCuePoints.push(_loc2_);
         }
         else
         {
            _loc5_ = this.getCuePointIndex(this.allCuePoints,true,_loc2_.time);
            _loc5_ = this.allCuePoints[_loc5_].time <= _loc2_.time ? _loc5_ + 1 : 0;
            this.allCuePoints.splice(_loc5_,0,_loc2_);
         }
      }
      delete this._disabledCuePointsByNameOnly;
      this._disabledCuePointsByNameOnly = null;
   }
   function processCuePointsProperty(cuePoints)
   {
      if(cuePoints == null || cuePoints.length == 0)
      {
         return undefined;
      }
      var _loc4_ = 0;
      var _loc8_ = undefined;
      var _loc6_ = undefined;
      var _loc7_ = undefined;
      var _loc5_ = undefined;
      var _loc9_ = undefined;
      var _loc2_ = 0;
      while(_loc2_ < cuePoints.length - 1)
      {
         switch(_loc4_)
         {
            case 6:
               this.addOrDisable(_loc9_,_loc5_);
               _loc4_ = 0;
            case 0:
               if(cuePoints[_loc2_++] != "t")
               {
                  throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"unexpected cuePoint parameter format");
               }
               if(isNaN(cuePoints[_loc2_]))
               {
                  throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"time must be number");
               }
               _loc5_ = new Object();
               break;
            case 1:
               if(cuePoints[_loc2_++] != "n")
               {
                  throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"unexpected cuePoint parameter format");
               }
               if(cuePoints[_loc2_] == null)
               {
                  throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"name cannot be null or undefined");
               }
               _loc5_.name = this.unescape(cuePoints[_loc2_]);
               _loc4_ = _loc4_ + 1;
               break;
            case 2:
               if(cuePoints[_loc2_++] != "t")
               {
                  throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"unexpected cuePoint parameter format");
               }
               if(isNaN(cuePoints[_loc2_]))
               {
                  throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"type must be number");
               }
               switch(cuePoints[_loc2_])
               {
                  case 0:
                     _loc5_.type = "event";
                     break;
                  case 1:
                     _loc5_.type = "navigation";
                     break;
                  case 2:
                     _loc5_.type = "actionscript";
                     break;
                  default:
                     throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"type must be 0, 1 or 2");
               }
               _loc4_ = _loc4_ + 1;
               break;
            case 3:
               if(cuePoints[_loc2_++] != "d")
               {
                  throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"unexpected cuePoint parameter format");
               }
               if(isNaN(cuePoints[_loc2_]))
               {
                  throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"disabled must be number");
               }
               _loc9_ = cuePoints[_loc2_] != 0;
               _loc4_ = _loc4_ + 1;
               break;
            case 4:
               if(cuePoints[_loc2_++] != "p")
               {
                  throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"unexpected cuePoint parameter format");
               }
               if(isNaN(cuePoints[_loc2_]))
               {
                  throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"num params must be number");
               }
               _loc8_ = cuePoints[_loc2_];
               _loc4_ = _loc4_ + 1;
               if(_loc8_ == 0)
               {
                  _loc4_ = _loc4_ + 1;
               }
               else
               {
                  _loc5_.parameters = new Object();
               }
               break;
            case 5:
               _loc6_ = cuePoints[_loc2_++];
               _loc7_ = cuePoints[_loc2_];
               if(typeof _loc6_ == "string")
               {
                  _loc6_ = this.unescape(_loc6_);
               }
               if(typeof _loc7_ == "string")
               {
                  _loc7_ = this.unescape(_loc7_);
               }
               _loc5_.parameters[_loc6_] = _loc7_;
               _loc8_ = _loc8_ - 1;
               if(_loc8_ == 0)
               {
                  _loc4_ = _loc4_ + 1;
               }
               break;
         }
         _loc5_.time = cuePoints[_loc2_] / 1000;
         _loc4_ = _loc4_ + 1;
         _loc2_ = _loc2_ + 1;
      }
      if(_loc4_ == 6)
      {
         this.addOrDisable(_loc9_,_loc5_);
      }
      throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"unexpected end of cuePoint param string");
   }
   function addOrDisable(disable, cuePoint)
   {
      if(disable)
      {
         if(cuePoint.type == "actionscript")
         {
            throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"Cannot disable actionscript cue points");
         }
         this.setFLVCuePointEnabled(false,cuePoint);
      }
      else if(cuePoint.type == "actionscript")
      {
         this.addASCuePoint(cuePoint);
      }
   }
   function unescape(origStr)
   {
      var _loc3_ = origStr;
      var _loc1_ = 0;
      while(_loc1_ < mx.video.CuePointManager.cuePointsReplace.length)
      {
         var _loc2_ = _loc3_.split(mx.video.CuePointManager.cuePointsReplace[_loc1_++]);
         if(_loc2_.length > 1)
         {
            _loc3_ = _loc2_.join(mx.video.CuePointManager.cuePointsReplace[_loc1_]);
         }
         _loc1_ = _loc1_ + 1;
      }
      return _loc3_;
   }
   function getCuePointIndex(cuePointArray, closeIsOK, time, name, start, len)
   {
      if(cuePointArray == null || cuePointArray.length < 1)
      {
         return -1;
      }
      var _loc13_ = isNaN(time) || time < 0;
      var _loc16_ = name == null;
      if(_loc13_ && _loc16_)
      {
         throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"time must be number and/or name must not be undefined or null");
      }
      if(start == null)
      {
         start = 0;
      }
      if(len == null)
      {
         len = cuePointArray.length;
      }
      if(!_loc16_ && (closeIsOK || _loc13_))
      {
         var _loc8_ = undefined;
         var _loc2_ = undefined;
         if(_loc13_)
         {
            _loc8_ = start;
         }
         else
         {
            _loc8_ = this.getCuePointIndex(cuePointArray,closeIsOK,time);
         }
         _loc2_ = _loc8_;
         while(_loc2_ >= start)
         {
            if(cuePointArray[_loc2_].name == name)
            {
               break;
            }
            _loc2_ = _loc2_ - 1;
         }
         if(_loc2_ >= start)
         {
            return _loc2_;
         }
         _loc2_ = _loc8_ + 1;
         while(_loc2_ < len)
         {
            if(cuePointArray[_loc2_].name == name)
            {
               break;
            }
            _loc2_ = _loc2_ + 1;
         }
         if(_loc2_ < len)
         {
            return _loc2_;
         }
         return -1;
      }
      var _loc6_ = undefined;
      if(len <= this._linearSearchTolerance)
      {
         var _loc11_ = start + len;
         var _loc3_ = start;
         while(_loc3_ < _loc11_)
         {
            _loc6_ = mx.video.CuePointManager.cuePointCompare(time,name,cuePointArray[_loc3_]);
            if(_loc6_ == 0)
            {
               return _loc3_;
            }
            if(_loc6_ < 0)
            {
               break;
            }
            _loc3_ = _loc3_ + 1;
         }
         if(closeIsOK)
         {
            if(_loc3_ > 0)
            {
               return _loc3_ - 1;
            }
            return 0;
         }
         return -1;
      }
      var _loc12_ = Math.floor(len / 2);
      var _loc15_ = start + _loc12_;
      _loc6_ = mx.video.CuePointManager.cuePointCompare(time,name,cuePointArray[_loc15_]);
      if(_loc6_ < 0)
      {
         return this.getCuePointIndex(cuePointArray,closeIsOK,time,name,start,_loc12_);
      }
      if(_loc6_ > 0)
      {
         return this.getCuePointIndex(cuePointArray,closeIsOK,time,name,_loc15_ + 1,_loc12_ - 1 + len % 2);
      }
      return _loc15_;
   }
   function getNextCuePointIndexWithName(name, array, index)
   {
      if(name == null)
      {
         throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"name cannot be undefined or null");
      }
      if(array == null)
      {
         throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"cuePoint.array undefined");
      }
      if(isNaN(index) || index < -1 || index >= array.length)
      {
         throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"cuePoint.index must be number between -1 and cuePoint.array.length");
      }
      var _loc1_ = undefined;
      _loc1_ = index + 1;
      while(_loc1_ < array.length)
      {
         if(array[_loc1_].name == name)
         {
            break;
         }
         _loc1_ = _loc1_ + 1;
      }
      if(_loc1_ < array.length)
      {
         return _loc1_;
      }
      return -1;
   }
   static function cuePointCompare(time, name, cuePoint)
   {
      var _loc1_ = Math.round(time * 1000);
      var _loc2_ = Math.round(cuePoint.time * 1000);
      if(_loc1_ < _loc2_)
      {
         return -1;
      }
      if(_loc1_ > _loc2_)
      {
         return 1;
      }
      if(name != null)
      {
         if(name == cuePoint.name)
         {
            return 0;
         }
         if(name < cuePoint.name)
         {
            return -1;
         }
         return 1;
      }
      return 0;
   }
   function getCuePoint(cuePointArray, closeIsOK, timeNameOrCuePoint)
   {
      var _loc2_ = undefined;
      switch(typeof timeNameOrCuePoint)
      {
         case "string":
            _loc2_ = {name:timeNameOrCuePoint};
            break;
         case "number":
            _loc2_ = {time:timeNameOrCuePoint};
            break;
         case "object":
            _loc2_ = timeNameOrCuePoint;
      }
      var _loc3_ = this.getCuePointIndex(cuePointArray,closeIsOK,_loc2_.time,_loc2_.name);
      if(_loc3_ < 0)
      {
         return null;
      }
      _loc2_ = mx.video.CuePointManager.deepCopyObject(cuePointArray[_loc3_]);
      _loc2_.array = cuePointArray;
      _loc2_.index = _loc3_;
      return _loc2_;
   }
   function getNextCuePointWithName(cuePoint)
   {
      if(cuePoint == null)
      {
         throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"cuePoint parameter undefined");
      }
      if(isNaN(cuePoint.time) || cuePoint.time < 0)
      {
         throw new mx.video.VideoError(mx.video.VideoError.ILLEGAL_CUE_POINT,"time must be number");
      }
      var _loc3_ = this.getNextCuePointIndexWithName(cuePoint.name,cuePoint.array,cuePoint.index);
      if(_loc3_ < 0)
      {
         return null;
      }
      var _loc4_ = mx.video.CuePointManager.deepCopyObject(cuePoint.array[_loc3_]);
      _loc4_.array = cuePoint.array;
      _loc4_.index = _loc3_;
      return _loc4_;
   }
   static function deepCopyObject(obj, recurseLevel)
   {
      if(obj == null || typeof obj != "object")
      {
         return obj;
      }
      if(recurseLevel == null)
      {
         recurseLevel = 0;
      }
      var _loc2_ = new Object();
      for(var _loc4_ in obj)
      {
         if(!(recurseLevel == 0 && (_loc4_ == "array" || _loc4_ == "index")))
         {
            if(typeof obj[_loc4_] == "object")
            {
               _loc2_[_loc4_] = mx.video.CuePointManager.deepCopyObject(obj[_loc4_],recurseLevel + 1);
            }
            else
            {
               _loc2_[_loc4_] = obj[_loc4_];
            }
         }
      }
      return _loc2_;
   }
}
