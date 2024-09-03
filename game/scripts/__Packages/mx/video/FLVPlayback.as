class mx.video.FLVPlayback extends MovieClip
{
   var _autoPlay;
   var _autoRewind;
   var _autoSize;
   var _bufferTime;
   var _contentPath;
   var _cuePoints;
   var _idleTimeout;
   var _isLive;
   var _aspectRatio;
   var _seekToPrevOffset;
   var _playheadUpdateInterval;
   var _progressInterval;
   var _totalTime;
   var _transform;
   var _volume;
   var _skinAutoHide;
   var _bufferingBarHides;
   var _origHeight;
   var __height;
   var _origWidth;
   var __width;
   var _scaleX;
   var _scaleY;
   var _preSeekTime;
   var _firstStreamReady;
   var _firstStreamShown;
   var _activeVP;
   var _visibleVP;
   var _topVP;
   var _vp;
   var _vpState;
   var _cpMgr;
   var boundingBox_mc;
   var preview_mc;
   var dispatchEvent;
   var _uiMgr;
   var _bufferingBar;
   var _backButton;
   var _forwardButton;
   var _muteButton;
   var _pauseButton;
   var _playButton;
   var _playPauseButton;
   var _seekBar;
   var _seekBarInterval;
   var _seekBarScrubTolerance;
   var _skin;
   var _stopButton;
   var _volumeBar;
   var _volumeBarInterval;
   var _volumeBarScrubTolerance;
   static var version = "1.0.2.8";
   static var shortVersion = "1.0.2";
   static var DISCONNECTED = "disconnected";
   static var STOPPED = "stopped";
   static var PLAYING = "playing";
   static var PAUSED = "paused";
   static var BUFFERING = "buffering";
   static var LOADING = "loading";
   static var CONNECTION_ERROR = "connectionError";
   static var REWINDING = "rewinding";
   static var SEEKING = "seeking";
   static var ALL = "all";
   static var EVENT = "event";
   static var NAVIGATION = "navigation";
   static var FLV = "flv";
   static var ACTIONSCRIPT = "actionscript";
   static var VP_DEPTH_OFFSET = 100;
   static var SEEK_TO_PREV_OFFSET_DEFAULT = 1;
   function FLVPlayback()
   {
      super();
      mx.events.EventDispatcher.initialize(this);
      if(this._autoPlay == undefined)
      {
         this._autoPlay = true;
      }
      if(this._autoRewind == undefined)
      {
         this._autoRewind = true;
      }
      if(this._autoSize == undefined)
      {
         this._autoSize = false;
      }
      if(this._bufferTime == undefined)
      {
         this._bufferTime = 0.1;
      }
      if(this._contentPath == undefined)
      {
         this._contentPath = "";
      }
      if(this._cuePoints == undefined)
      {
         this._cuePoints = null;
      }
      if(this._idleTimeout == undefined)
      {
         this._idleTimeout = mx.video.VideoPlayer.DEFAULT_IDLE_TIMEOUT_INTERVAL;
      }
      if(this._isLive == undefined)
      {
         this._isLive = false;
      }
      if(this._aspectRatio == undefined)
      {
         this._aspectRatio = true;
      }
      if(this._seekToPrevOffset == undefined)
      {
         this._seekToPrevOffset = mx.video.FLVPlayback.SEEK_TO_PREV_OFFSET_DEFAULT;
      }
      if(this._playheadUpdateInterval == undefined)
      {
         this._playheadUpdateInterval = mx.video.VideoPlayer.DEFAULT_UPDATE_PROGRESS_INTERVAL;
      }
      if(this._progressInterval == undefined)
      {
         this._progressInterval = mx.video.VideoPlayer.DEFAULT_UPDATE_TIME_INTERVAL;
      }
      if(this._totalTime == undefined)
      {
         this._totalTime = 0;
      }
      if(this._transform == undefined)
      {
         this._transform = null;
      }
      if(this._volume == undefined)
      {
         this._volume = 100;
      }
      if(this._skinAutoHide == undefined)
      {
         this._skinAutoHide = false;
      }
      if(this._bufferingBarHides == undefined)
      {
         this._bufferingBarHides = false;
      }
      this._origHeight = this.__height = this._height;
      this._origWidth = this.__width = this._width;
      this._scaleX = 100;
      this._scaleY = 100;
      this._xscale = 100;
      this._yscale = 100;
      this._preSeekTime = -1;
      this._firstStreamReady = false;
      this._firstStreamShown = false;
      this.createUIManager();
      this._activeVP = 0;
      this._visibleVP = 0;
      this._topVP = 0;
      this._vp = new Array();
      this._vpState = new Array();
      this._cpMgr = new Array();
      this.createVideoPlayer(0);
      this._vp[0].visible = false;
      this._vp[0].volume = 0;
      this.boundingBox_mc._visible = false;
      this.boundingBox_mc.unloadMovie();
      delete this.boundingBox_mc;
      if(_global.isLivePreview)
      {
         this.createLivePreviewMovieClip();
         this.setSize(this.__width,this.__height);
      }
      this._cpMgr[0].processCuePointsProperty(this._cuePoints);
      delete this._cuePoints;
      this._cuePoints = null;
   }
   function setSize(w, h)
   {
      if(_global.isLivePreview)
      {
         if(this.preview_mc == undefined)
         {
            this.createLivePreviewMovieClip();
         }
         this.preview_mc.box_mc._width = w;
         this.preview_mc.box_mc._height = h;
         if(this.preview_mc.box_mc._width < this.preview_mc.icon_mc._width || this.preview_mc.box_mc._height < this.preview_mc.icon_mc._height)
         {
            this.preview_mc.icon_mc._visible = false;
         }
         else
         {
            this.preview_mc.icon_mc._visible = true;
            this.preview_mc.icon_mc._x = (this.preview_mc.box_mc._width - this.preview_mc.icon_mc._width) / 2;
            this.preview_mc.icon_mc._y = (this.preview_mc.box_mc._height - this.preview_mc.icon_mc._height) / 2;
         }
      }
      if(w == this.width && h == this.height)
      {
         return undefined;
      }
      this.__width = w;
      this.__height = h;
      var _loc3_ = 0;
      while(_loc3_ < this._vp.length)
      {
         if(this._vp[_loc3_] != undefined)
         {
            this._vp[_loc3_].setSize(w,h);
         }
         _loc3_ = _loc3_ + 1;
      }
      this.dispatchEvent({type:"resize",x:this.x,y:this.y,width:w,height:h});
   }
   function setScale(xs, ys)
   {
      if(xs == this.scaleX && ys == this.scaleY)
      {
         return undefined;
      }
      this._scaleX = xs;
      this._scaleY = ys;
      var _loc2_ = 0;
      while(_loc2_ < this._vp.length)
      {
         if(this._vp[_loc2_] != undefined)
         {
            this._vp[_loc2_].setSize(this._origWidth * xs / 100,this._origHeight * ys / 100);
         }
         _loc2_ = _loc2_ + 1;
      }
      this.dispatchEvent({type:"resize",x:this.x,y:this.y,width:this.width,height:this.height});
   }
   function handleEvent(e)
   {
      var _loc3_ = e.state;
      if(e.state != undefined && e.target._name == this._visibleVP && this.scrubbing)
      {
         _loc3_ = mx.video.FLVPlayback.SEEKING;
      }
      if(e.type == "metadataReceived")
      {
         this._cpMgr[e.target._name].processFLVCuePoints(e.info.cuePoints);
         this.dispatchEvent({type:e.type,info:e.info,vp:e.target._name});
      }
      else if(e.type == "cuePoint")
      {
         if(this._cpMgr[e.target._name].isFLVCuePointEnabled(e.info))
         {
            this.dispatchEvent({type:e.type,info:e.info,vp:e.target._name});
         }
      }
      else if(e.type == "rewind")
      {
         this.dispatchEvent({type:e.type,auto:true,state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
         this._cpMgr[e.target._name].resetASCuePointIndex(e.playheadTime);
      }
      else if(e.type == "resize")
      {
         this.dispatchEvent({type:e.type,x:this.x,y:this.y,width:this.width,height:this.height,auto:true,vp:e.target._name});
      }
      else if(e.type == "playheadUpdate")
      {
         this.dispatchEvent({type:e.type,state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
         if(this._preSeekTime >= 0 && e.target.state != mx.video.FLVPlayback.SEEKING)
         {
            var _loc5_ = this._preSeekTime;
            this._preSeekTime = -1;
            this._cpMgr[e.target._name].resetASCuePointIndex(e.playheadTime);
            this.dispatchEvent({type:"seek",state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
            if(_loc5_ < e.playheadTime)
            {
               this.dispatchEvent({type:"fastForward",state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
            }
            else if(_loc5_ > e.playheadTime)
            {
               this.dispatchEvent({type:"rewind",auto:false,state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
            }
         }
         this._cpMgr[e.target._name].dispatchASCuePoints();
      }
      else if(e.type == "stateChange")
      {
         var _loc4_ = e.target._name;
         if(_loc4_ == this._visibleVP && this.scrubbing)
         {
            return undefined;
         }
         if(e.state == mx.video.VideoPlayer.RESIZING)
         {
            return undefined;
         }
         if(this._vpState[_loc4_].prevState == mx.video.FLVPlayback.LOADING && this._vpState[_loc4_].autoPlay && e.state == mx.video.FLVPlayback.STOPPED)
         {
            return undefined;
         }
         this._vpState[_loc4_].prevState = e.state;
         this.dispatchEvent({type:e.type,state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
         if(this._vp[e.target._name].state != _loc3_)
         {
            return undefined;
         }
         switch(_loc3_)
         {
            case mx.video.FLVPlayback.BUFFERING:
               this.dispatchEvent({type:"buffering",state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
               break;
            case mx.video.FLVPlayback.PAUSED:
               this.dispatchEvent({type:"paused",state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
               break;
            case mx.video.FLVPlayback.PLAYING:
               this.dispatchEvent({type:"playing",state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
               break;
            case mx.video.FLVPlayback.STOPPED:
               this.dispatchEvent({type:"stopped",state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
         }
      }
      else if(e.type == "progress")
      {
         this.dispatchEvent({type:e.type,bytesLoaded:e.bytesLoaded,bytesTotal:e.bytesTotal,vp:e.target._name});
      }
      else if(e.type == "ready")
      {
         _loc4_ = e.target._name;
         if(!this._firstStreamReady)
         {
            if(_loc4_ == this._visibleVP)
            {
               this._firstStreamReady = true;
               if(this._uiMgr.skinReady && !this._firstStreamShown)
               {
                  this._uiMgr.visible = true;
                  this.showFirstStream();
               }
            }
         }
         else if(this._firstStreamShown && _loc3_ == mx.video.FLVPlayback.STOPPED && this._vpState[_loc4_].autoPlay)
         {
            this._vp[_loc4_].play();
         }
         this.dispatchEvent({type:e.type,state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
      }
      else if(e.type == "close" || e.type == "complete")
      {
         this.dispatchEvent({type:e.type,state:_loc3_,playheadTime:e.playheadTime,vp:e.target._name});
      }
   }
   function load(contentPath, totalTime, isLive)
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return undefined;
      }
      if(contentPath == null || contentPath == "")
      {
         return undefined;
      }
      this.autoPlay = false;
      if(totalTime != undefined)
      {
         this.totalTime = totalTime;
      }
      if(isLive != undefined)
      {
         this.isLive = isLive;
      }
      this.contentPath = contentPath;
   }
   function play(contentPath, totalTime, isLive)
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return undefined;
      }
      if(contentPath == undefined)
      {
         this._vp[this._activeVP].play();
      }
      else
      {
         this.autoPlay = true;
         if(totalTime != undefined)
         {
            this.totalTime = totalTime;
         }
         if(isLive != undefined)
         {
            this.isLive = isLive;
         }
         this.contentPath = contentPath;
      }
   }
   function pause()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return undefined;
      }
      this._vp[this._activeVP].pause();
   }
   function stop()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return undefined;
      }
      this._vp[this._activeVP].stop();
   }
   function seek(time)
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return undefined;
      }
      this._preSeekTime = this.playheadTime;
      this._vp[this._activeVP].seek(time);
   }
   function seekSeconds(time)
   {
      this.seek(time);
   }
   function seekPercent(percent)
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return undefined;
      }
      if(percent < 0 || percent > 100 || this._vp[this._activeVP].totalTime == null || this._vp[this._activeVP].totalTime <= 0)
      {
         throw new mx.video.VideoError(mx.video.VideoError.INVALID_SEEK);
      }
      this.seek(this._vp[this._activeVP].totalTime * percent / 100);
   }
   function get playheadPercentage()
   {
      if(this._vp[this._activeVP].totalTime == null || this._vp[this._activeVP].totalTime <= 0)
      {
         return undefined;
      }
      return this._vp[this._activeVP].playheadTime / this._vp[this._activeVP].totalTime * 100;
   }
   function set playheadPercentage(percent)
   {
      this.seekPercent(percent);
   }
   function seekToNavCuePoint(timeNameOrCuePoint)
   {
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
      if(_loc3_.name == null || typeof _loc3_.name != "string")
      {
         this.seekToNextNavCuePoint(_loc3_.time);
         return undefined;
      }
      if(isNaN(_loc3_.time))
      {
         _loc3_.time = 0;
      }
      var _loc2_ = this.findNearestCuePoint(timeNameOrCuePoint,mx.video.FLVPlayback.NAVIGATION);
      while(_loc2_ != null && (_loc2_.time < _loc3_.time || !this.isFLVCuePointEnabled(_loc2_)))
      {
         _loc2_ = this.findNextCuePointWithName(_loc2_);
      }
      if(_loc2_ == null)
      {
         throw new mx.video.VideoError(mx.video.VideoError.INVALID_SEEK);
      }
      this.seek(_loc2_.time);
   }
   function seekToNextNavCuePoint(time)
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return undefined;
      }
      if(isNaN(time) || time < 0)
      {
         time = this._vp[this._activeVP].playheadTime + 0.001;
      }
      var _loc3_ = undefined;
      _loc3_ = this.findNearestCuePoint(time,mx.video.FLVPlayback.NAVIGATION);
      if(_loc3_ == null)
      {
         this.seek(this._vp[this._activeVP].totalTime);
         return undefined;
      }
      var _loc2_ = _loc3_.index;
      if(_loc3_.time < time)
      {
         _loc2_ = _loc2_ + 1;
      }
      while(_loc2_ < _loc3_.array.length && !this.isFLVCuePointEnabled(_loc3_.array[_loc2_]))
      {
         _loc2_ = _loc2_ + 1;
      }
      if(_loc2_ >= _loc3_.array.length)
      {
         var _loc5_ = this._vp[this._activeVP].totalTime;
         if(_loc3_.array[_loc3_.array.length - 1].time > _loc5_)
         {
            _loc5_ = _loc3_.array[_loc3_.array.length - 1];
         }
         this.seek(_loc5_);
      }
      else
      {
         this.seek(_loc3_.array[_loc2_].time);
      }
   }
   function seekToPrevNavCuePoint(time)
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return undefined;
      }
      if(isNaN(time) || time < 0)
      {
         time = this._vp[this._activeVP].playheadTime;
      }
      var _loc3_ = this.findNearestCuePoint(time,mx.video.FLVPlayback.NAVIGATION);
      if(_loc3_ == null)
      {
         this.seek(0);
         return undefined;
      }
      var _loc2_ = _loc3_.index;
      while(_loc2_ >= 0 && (!this.isFLVCuePointEnabled(_loc3_.array[_loc2_]) || _loc3_.array[_loc2_].time >= time - this._seekToPrevOffset))
      {
         _loc2_ = _loc2_ - 1;
      }
      if(_loc2_ < 0)
      {
         this.seek(0);
      }
      else
      {
         this.seek(_loc3_.array[_loc2_].time);
      }
   }
   function addASCuePoint(timeOrCuePoint, name, parameters)
   {
      return this._cpMgr[this._activeVP].addASCuePoint(timeOrCuePoint,name,parameters);
   }
   function removeASCuePoint(timeNameOrCuePoint)
   {
      return this._cpMgr[this._activeVP].removeASCuePoint(timeNameOrCuePoint);
   }
   function findCuePoint(timeNameOrCuePoint, type)
   {
      switch(type)
      {
         case "event":
            return this._cpMgr[this._activeVP].getCuePoint(this._cpMgr[this._activeVP].eventCuePoints,false,timeNameOrCuePoint);
         case "navigation":
            return this._cpMgr[this._activeVP].getCuePoint(this._cpMgr[this._activeVP].navCuePoints,false,timeNameOrCuePoint);
         case "flv":
            return this._cpMgr[this._activeVP].getCuePoint(this._cpMgr[this._activeVP].flvCuePoints,false,timeNameOrCuePoint);
         case "actionscript":
            return this._cpMgr[this._activeVP].getCuePoint(this._cpMgr[this._activeVP].asCuePoints,false,timeNameOrCuePoint);
         case "all":
         default:
            return this._cpMgr[this._activeVP].getCuePoint(this._cpMgr[this._activeVP].allCuePoints,false,timeNameOrCuePoint);
      }
   }
   function findNearestCuePoint(timeNameOrCuePoint, type)
   {
      switch(type)
      {
         case "event":
            return this._cpMgr[this._activeVP].getCuePoint(this._cpMgr[this._activeVP].eventCuePoints,true,timeNameOrCuePoint);
         case "navigation":
            return this._cpMgr[this._activeVP].getCuePoint(this._cpMgr[this._activeVP].navCuePoints,true,timeNameOrCuePoint);
         case "flv":
            return this._cpMgr[this._activeVP].getCuePoint(this._cpMgr[this._activeVP].flvCuePoints,true,timeNameOrCuePoint);
         case "actionscript":
            return this._cpMgr[this._activeVP].getCuePoint(this._cpMgr[this._activeVP].asCuePoints,true,timeNameOrCuePoint);
         case "all":
         default:
            return this._cpMgr[this._activeVP].getCuePoint(this._cpMgr[this._activeVP].allCuePoints,true,timeNameOrCuePoint);
      }
   }
   function findNextCuePointWithName(cuePoint)
   {
      return this._cpMgr[this._activeVP].getNextCuePointWithName(cuePoint);
   }
   function setFLVCuePointEnabled(enabled, timeNameOrCuePoint)
   {
      return this._cpMgr[this._activeVP].setFLVCuePointEnabled(enabled,timeNameOrCuePoint);
   }
   function isFLVCuePointEnabled(timeNameOrCuePoint)
   {
      return this._cpMgr[this._activeVP].isFLVCuePointEnabled(timeNameOrCuePoint);
   }
   function getNextHighestDepth()
   {
      var _loc2_ = super.getNextHighestDepth();
      return _loc2_ >= 1000 ? _loc2_ : 1000;
   }
   function bringVideoPlayerToFront(index)
   {
      if(index == this._topVP || this._vp[index] == undefined)
      {
         return undefined;
      }
      this._vp[this._topVP].swapDepths(this._vp[index].getDepth());
      this._topVP = index;
   }
   function getVideoPlayer(index)
   {
      return this._vp[index];
   }
   function closeVideoPlayer(index)
   {
      if(this._vp[index] == undefined)
      {
         return undefined;
      }
      if(index == 0)
      {
         throw new mx.video.VideoError(mx.video.VideoError.DELETE_DEFAULT_PLAYER);
      }
      if(this._visibleVP == index)
      {
         this.visibleVideoPlayerIndex = 0;
      }
      if(this._activeVP == index)
      {
         this.activeVideoPlayerIndex = 0;
      }
      this._vp[index].close();
      this._vp[index].unloadMovie();
      delete this._vp[index];
      this._vp[index] = undefined;
   }
   function get activeVideoPlayerIndex()
   {
      return this._activeVP;
   }
   function set activeVideoPlayerIndex(i)
   {
      if(this._activeVP == i)
      {
         return;
      }
      if(this._vp[this._activeVP].onEnterFrame != undefined)
      {
         this.doContentPathConnect();
      }
      this._activeVP = i;
      if(this._vp[this._activeVP] == undefined)
      {
         this.createVideoPlayer(this._activeVP);
         this._vp[this._activeVP].visible = false;
         this._vp[this._activeVP].volume = 0;
      }
   }
   function get autoPlay()
   {
      if(this._vpState[this._activeVP] == undefined)
      {
         return this._autoPlay;
      }
      return this._vpState[this._activeVP].autoPlay;
   }
   function set autoPlay(flag)
   {
      if(this._activeVP == 0 || this._activeVP == undefined)
      {
         this._autoPlay = flag;
      }
      this._vpState[this._activeVP].autoPlay = flag;
   }
   function get autoRewind()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return this._autoRewind;
      }
      return this._vp[this._activeVP].autoRewind;
   }
   function set autoRewind(flag)
   {
      if(this._activeVP == 0 || this._activeVP == undefined)
      {
         this._autoRewind = flag;
      }
      this._vp[this._activeVP].autoRewind = flag;
   }
   function get autoSize()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return this._autoSize;
      }
      return this._vp[this._activeVP].autoSize;
   }
   function set autoSize(flag)
   {
      if(this._activeVP == 0 || this._activeVP == undefined)
      {
         this._autoSize = flag;
      }
      this._vp[this._activeVP].autoSize = flag;
   }
   function get bitrate()
   {
      return this.ncMgr.getBitrate();
   }
   function set bitrate(b)
   {
      this.ncMgr.setBitrate(b);
   }
   function get buffering()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return false;
      }
      return this._vp[this._activeVP].state == mx.video.FLVPlayback.BUFFERING;
   }
   function get bufferingBar()
   {
      if(this._uiMgr != null)
      {
         this._bufferingBar = this._uiMgr.getControl(mx.video.UIManager.BUFFERING_BAR);
      }
      return this._bufferingBar;
   }
   function set bufferingBar(s)
   {
      this._bufferingBar = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.BUFFERING_BAR,s);
      }
   }
   function get bufferingBarHidesAndDisablesOthers()
   {
      if(this._uiMgr != null)
      {
         this._bufferingBarHides = this._uiMgr.bufferingBarHidesAndDisablesOthers;
      }
      return this._bufferingBarHides;
   }
   function set bufferingBarHidesAndDisablesOthers(b)
   {
      this._bufferingBarHides = b;
      if(this._uiMgr != null)
      {
         this._uiMgr.bufferingBarHidesAndDisablesOthers = b;
      }
   }
   function get backButton()
   {
      if(this._uiMgr != null)
      {
         this._backButton = this._uiMgr.getControl(mx.video.UIManager.BACK_BUTTON);
      }
      return this._backButton;
   }
   function set backButton(s)
   {
      this._backButton = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.BACK_BUTTON,s);
      }
   }
   function get bufferTime()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return this._bufferTime;
      }
      return this._vp[this._activeVP].bufferTime;
   }
   function set bufferTime(aTime)
   {
      if(this._activeVP == 0 || this._activeVP == undefined)
      {
         this._bufferTime = aTime;
      }
      this._vp[this._activeVP].bufferTime = aTime;
   }
   function get bytesLoaded()
   {
      return this._vp[this._activeVP].bytesLoaded;
   }
   function get bytesTotal()
   {
      return this._vp[this._activeVP].bytesTotal;
   }
   function get contentPath()
   {
      if(this._vp[this._activeVP] == undefined || this._vp[this._activeVP].onEnterFrame != undefined)
      {
         return this._contentPath;
      }
      return this._vp[this._activeVP].url;
   }
   function set contentPath(url)
   {
      if(_global.isLivePreview)
      {
         return;
      }
      if(this._vp[this._activeVP] == undefined)
      {
         if(url == this._contentPath)
         {
            return;
         }
         this._contentPath = url;
      }
      else
      {
         if(this._vp[this._activeVP].url == url)
         {
            return;
         }
         this._vpState[this._activeVP].minProgressPercent = undefined;
         if(this._vp[this._activeVP].onEnterFrame != undefined)
         {
            delete this._vp[this._activeVP].onEnterFrame;
            this._vp[this._activeVP].onEnterFrame = undefined;
         }
         this._cpMgr[this._activeVP].reset();
         if(this._vpState[this._activeVP].autoPlay && this._firstStreamShown)
         {
            this._vp[this._activeVP].play(url,this._vpState[this._activeVP].isLive,this._vpState[this._activeVP].totalTime);
         }
         else
         {
            this._vp[this._activeVP].load(url,this._vpState[this._activeVP].isLive,this._vpState[this._activeVP].totalTime);
         }
         this._vpState[this._activeVP].isLiveSet = false;
         this._vpState[this._activeVP].totalTimeSet = false;
      }
   }
   function set cuePoints(cp)
   {
      if(this._cuePoints != undefined)
      {
         return;
      }
      this._cuePoints = cp;
   }
   function get forwardButton()
   {
      if(this._uiMgr != null)
      {
         this._forwardButton = this._uiMgr.getControl(mx.video.UIManager.FORWARD_BUTTON);
      }
      return this._forwardButton;
   }
   function set forwardButton(s)
   {
      this._forwardButton = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.FORWARD_BUTTON,s);
      }
   }
   function get height()
   {
      if(_global.isLivePreview)
      {
         return this.__height;
      }
      if(this._vp[this._visibleVP] != undefined)
      {
         this.__height = this._vp[this._visibleVP].height;
      }
      return this.__height;
   }
   function set height(h)
   {
      this.setSize(this.width,h);
   }
   function get idleTimeout()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return this._idleTimeout;
      }
      return this._vp[this._activeVP].idleTimeout;
   }
   function set idleTimeout(aTime)
   {
      if(this._activeVP == 0 || this._activeVP == undefined)
      {
         this._idleTimeout = aTime;
      }
      this._vp[this._activeVP].idleTimeout = aTime;
   }
   function get isRTMP()
   {
      if(_global.isLivePreview)
      {
         return true;
      }
      if(this._vp[this._activeVP] == undefined)
      {
         return undefined;
      }
      return this._vp[this._activeVP].isRTMP;
   }
   function get isLive()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return this._isLive;
      }
      if(this._vpState[this._activeVP].isLiveSet)
      {
         return this._vpState[this._activeVP].isLive;
      }
      return this._vp[this._activeVP].isLive;
   }
   function set isLive(flag)
   {
      if(this._activeVP == 0 || this._activeVP == undefined)
      {
         this._isLive = flag;
      }
      this._vpState[this._activeVP].isLive = flag;
      this._vpState[this._activeVP].isLiveSet = true;
   }
   function get maintainAspectRatio()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return this._aspectRatio;
      }
      return this._vp[this._activeVP].maintainAspectRatio;
   }
   function set maintainAspectRatio(flag)
   {
      if(this._activeVP == 0 || this._activeVP == undefined)
      {
         this._aspectRatio = flag;
      }
      this._vp[this._activeVP].maintainAspectRatio = flag;
   }
   function get metadata()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return null;
      }
      return this._vp[this._activeVP].metadata;
   }
   function get metadataLoaded()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return false;
      }
      return this._cpMgr[this._activeVP].metadataLoaded;
   }
   function get muteButton()
   {
      if(this._uiMgr != null)
      {
         this._muteButton = this._uiMgr.getControl(mx.video.UIManager.MUTE_BUTTON);
      }
      return this._muteButton;
   }
   function set muteButton(s)
   {
      this._muteButton = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.MUTE_BUTTON,s);
      }
   }
   function get ncMgr()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return null;
      }
      return this._vp[this._activeVP].ncMgr;
   }
   function get pauseButton()
   {
      if(this._uiMgr != null)
      {
         this._pauseButton = this._uiMgr.getControl(mx.video.UIManager.PAUSE_BUTTON);
      }
      return this._pauseButton;
   }
   function set pauseButton(s)
   {
      this._pauseButton = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.PAUSE_BUTTON,s);
      }
   }
   function get paused()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return false;
      }
      return this._vp[this._activeVP].state == mx.video.FLVPlayback.PAUSED;
   }
   function get playButton()
   {
      if(this._uiMgr != null)
      {
         this._playButton = this._uiMgr.getControl(mx.video.UIManager.PLAY_BUTTON);
      }
      return this._playButton;
   }
   function set playButton(s)
   {
      this._playButton = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.PLAY_BUTTON,s);
      }
   }
   function get playheadTime()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return 0;
      }
      return this._vp[this._activeVP].playheadTime;
   }
   function set playheadTime(position)
   {
      this.seek(position);
   }
   function get playheadUpdateInterval()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return this._playheadUpdateInterval;
      }
      return this._vp[this._activeVP].playheadUpdateInterval;
   }
   function set playheadUpdateInterval(aTime)
   {
      if(this._activeVP == 0 || this._activeVP == undefined)
      {
         this._playheadUpdateInterval = aTime;
      }
      this._cpMgr[this._activeVP].playheadUpdateInterval = aTime;
      this._vp[this._activeVP].playheadUpdateInterval = aTime;
   }
   function get playing()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return false;
      }
      return this._vp[this._activeVP].state == mx.video.FLVPlayback.PLAYING;
   }
   function get playPauseButton()
   {
      if(this._uiMgr != null)
      {
         this._playPauseButton = this._uiMgr.getControl(mx.video.UIManager.PLAY_PAUSE_BUTTON);
      }
      return this._playPauseButton;
   }
   function set playPauseButton(s)
   {
      this._playPauseButton = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.PLAY_PAUSE_BUTTON,s);
      }
   }
   function get preferredHeight()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return 0;
      }
      return this._vp[this._activeVP].videoHeight;
   }
   function get preferredWidth()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return 0;
      }
      return this._vp[this._activeVP].videoWidth;
   }
   function get progressInterval()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return this._progressInterval;
      }
      return this._vp[this._activeVP].progressInterval;
   }
   function set progressInterval(aTime)
   {
      if(this._activeVP == 0 || this._activeVP == undefined)
      {
         this._progressInterval = aTime;
      }
      this._vp[this._activeVP].progressInterval = aTime;
   }
   function get scaleX()
   {
      if(this._vp[this._visibleVP] != undefined)
      {
         this._scaleX = this._vp[this._visibleVP].width / this._origWidth * 100;
      }
      return this._scaleX;
   }
   function set scaleX(xs)
   {
      this.setScale(xs,this.scaleY);
   }
   function get scaleY()
   {
      if(this._vp[this._visibleVP] != undefined)
      {
         this._scaleY = this._vp[this._visibleVP].height / this._origHeight * 100;
      }
      return this._scaleY;
   }
   function set scaleY(ys)
   {
      this.setScale(this.scaleX,ys);
   }
   function get scrubbing()
   {
      var _loc2_ = this.seekBar;
      if(_loc2_ == undefined || _loc2_.isDragging == undefined)
      {
         return false;
      }
      return _loc2_.isDragging;
   }
   function get seekBar()
   {
      if(this._uiMgr != null)
      {
         this._seekBar = this._uiMgr.getControl(mx.video.UIManager.SEEK_BAR);
      }
      return this._seekBar;
   }
   function set seekBar(s)
   {
      this._seekBar = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.SEEK_BAR,s);
      }
   }
   function get seekBarInterval()
   {
      if(this._uiMgr != null)
      {
         this._seekBarInterval = this._uiMgr.seekBarInterval;
      }
      return this._seekBarInterval;
   }
   function set seekBarInterval(s)
   {
      this._seekBarInterval = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.seekBarInterval = this._seekBarInterval;
      }
   }
   function get seekBarScrubTolerance()
   {
      if(this._uiMgr != null)
      {
         this._seekBarScrubTolerance = this._uiMgr.seekBarScrubTolerance;
      }
      return this._seekBarScrubTolerance;
   }
   function set seekBarScrubTolerance(s)
   {
      this._seekBarScrubTolerance = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.seekBarScrubTolerance = this._seekBarScrubTolerance;
      }
   }
   function get seekToPrevOffset()
   {
      return this._seekToPrevOffset;
   }
   function set seekToPrevOffset(s)
   {
      this._seekToPrevOffset = s;
   }
   function get skin()
   {
      if(this._uiMgr != null)
      {
         this._skin = this._uiMgr.skin;
      }
      return this._skin;
   }
   function set skin(s)
   {
      this._skin = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.skin = s;
      }
   }
   function get skinAutoHide()
   {
      if(this._uiMgr != null)
      {
         this._skinAutoHide = this._uiMgr.skinAutoHide;
      }
      return this._skinAutoHide;
   }
   function set skinAutoHide(b)
   {
      if(_global.isLivePreview)
      {
         return;
      }
      this._skinAutoHide = b;
      if(this._uiMgr != null)
      {
         this._uiMgr.skinAutoHide = b;
      }
   }
   function get transform()
   {
      return this._transform;
   }
   function set transform(s)
   {
      this._transform = s;
      if(this._vp[this._activeVP] != undefined)
      {
         this._vp[this._activeVP].transform = this._transform;
      }
   }
   function get state()
   {
      if(_global.isLivePreview)
      {
         return mx.video.FLVPlayback.STOPPED;
      }
      if(this._vp[this._activeVP] == undefined)
      {
         return mx.video.FLVPlayback.DISCONNECTED;
      }
      if(this._activeVP == this._visibleVP && this.scrubbing)
      {
         return mx.video.FLVPlayback.SEEKING;
      }
      var _loc3_ = this._vp[this._activeVP].state;
      if(_loc3_ == mx.video.VideoPlayer.RESIZING)
      {
         return mx.video.FLVPlayback.LOADING;
      }
      if(this._vpState[this._activeVP].prevState == mx.video.FLVPlayback.LOADING && this._vpState[this._activeVP].autoPlay && _loc3_ == mx.video.FLVPlayback.STOPPED)
      {
         return mx.video.FLVPlayback.LOADING;
      }
      return _loc3_;
   }
   function get stateResponsive()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return false;
      }
      return this._vp[this._activeVP].stateResponsive;
   }
   function get stopButton()
   {
      if(this._uiMgr != null)
      {
         this._stopButton = this._uiMgr.getControl(mx.video.UIManager.STOP_BUTTON);
      }
      return this._stopButton;
   }
   function set stopButton(s)
   {
      this._stopButton = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.STOP_BUTTON,s);
      }
   }
   function get stopped()
   {
      if(this._vp[this._activeVP] == undefined)
      {
         return false;
      }
      return this._vp[this._activeVP].state == mx.video.FLVPlayback.STOPPED;
   }
   function get totalTime()
   {
      if(_global.isLivePreview)
      {
         return 1;
      }
      if(this._vp[this._activeVP] == undefined)
      {
         return this._totalTime;
      }
      if(this._vpState[this._activeVP].totalTimeSet)
      {
         return this._vpState[this._activeVP].totalTime;
      }
      return this._vp[this._activeVP].totalTime;
   }
   function set totalTime(aTime)
   {
      if(this._activeVP == 0 || this._activeVP == undefined)
      {
         this._totalTime = aTime;
      }
      this._vpState[this._activeVP].totalTime = aTime;
      this._vpState[this._activeVP].totalTimeSet = true;
   }
   function get version_1_0_2()
   {
      return "";
   }
   function set version_1_0_2(v)
   {
   }
   function get visible()
   {
      return this._visible;
   }
   function set visible(v)
   {
      this._visible = v;
   }
   function get visibleVideoPlayerIndex()
   {
      return this._visibleVP;
   }
   function set visibleVideoPlayerIndex(i)
   {
      if(this._visibleVP == i)
      {
         return;
      }
      var _loc3_ = this._visibleVP;
      if(this._vp[i] == undefined)
      {
         this.createVideoPlayer(i);
      }
      var _loc5_ = this._vp[i].height != this._vp[this._visibleVP].height || this._vp[i].width != this._vp[this._visibleVP].width;
      this._vp[this._visibleVP].visible = false;
      this._vp[this._visibleVP].volume = 0;
      this._visibleVP = i;
      if(this._firstStreamShown)
      {
         this._uiMgr.setupSkinAutoHide();
         this._vp[this._visibleVP].visible = true;
         if(!this.scrubbing)
         {
            this._vp[this._visibleVP].volume = this._volume;
         }
      }
      else if(this._vp[this._visibleVP].stateResponsive && this._vp[this._visibleVP].state != mx.video.FLVPlayback.DISCONNECTED && this._uiMgr.skinReady)
      {
         this._uiMgr.visible = true;
         this._uiMgr.setupSkinAutoHide();
         this._firstStreamReady = true;
         this.showFirstStream();
      }
      if(this._vp[_loc3_].height != this._vp[this._visibleVP].height || this._vp[_loc3_].width != this._vp[this._visibleVP].width)
      {
         this.dispatchEvent({type:"resize",x:this.x,y:this.y,width:this.width,height:this.height,auto:false,vp:this._visibleVP});
      }
      this._uiMgr.handleEvent({type:"stateChange",state:this._vp[this._visibleVP].state,vp:this._visibleVP});
      this._uiMgr.handleEvent({type:"playheadUpdate",playheadTime:this._vp[this._visibleVP].playheadTime,vp:this._visibleVP});
      if(this._vp[this._visibleVP].isRTMP)
      {
         this._uiMgr.handleEvent({type:"ready",vp:this._visibleVP});
      }
      else
      {
         this._uiMgr.handleEvent({type:"progress",bytesLoaded:this._vp[this._visibleVP].bytesLoaded,bytesTotal:this._vp[this._visibleVP].bytesTotal,vp:this._visibleVP});
      }
   }
   function get volume()
   {
      return this._volume;
   }
   function set volume(aVol)
   {
      if(this._volume == aVol)
      {
         return;
      }
      this._volume = aVol;
      if(!this.scrubbing)
      {
         this._vp[this._visibleVP].volume = this._volume;
      }
      this.dispatchEvent({type:"volumeUpdate",volume:aVol});
   }
   function get volumeBar()
   {
      if(this._uiMgr != null)
      {
         this._volumeBar = this._uiMgr.getControl(mx.video.UIManager.VOLUME_BAR);
      }
      return this._volumeBar;
   }
   function set volumeBar(s)
   {
      this._volumeBar = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.VOLUME_BAR,s);
      }
   }
   function get volumeBarInterval()
   {
      if(this._uiMgr != null)
      {
         this._volumeBarInterval = this._uiMgr.volumeBarInterval;
      }
      return this._volumeBarInterval;
   }
   function set volumeBarInterval(s)
   {
      this._volumeBarInterval = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.volumeBarInterval = this._volumeBarInterval;
      }
   }
   function get volumeBarScrubTolerance()
   {
      if(this._uiMgr != null)
      {
         this._volumeBarScrubTolerance = this._uiMgr.volumeBarScrubTolerance;
      }
      return this._volumeBarScrubTolerance;
   }
   function set volumeBarScrubTolerance(s)
   {
      this._volumeBarScrubTolerance = s;
      if(this._uiMgr != null)
      {
         this._uiMgr.volumeBarScrubTolerance = this._volumeBarScrubTolerance;
      }
   }
   function get width()
   {
      if(_global.isLivePreview)
      {
         return this.__width;
      }
      if(this._vp[this._visibleVP] != undefined)
      {
         this.__width = this._vp[this._visibleVP].width;
      }
      return this.__width;
   }
   function set width(w)
   {
      this.setSize(w,this.height);
   }
   function get x()
   {
      return this._x;
   }
   function set x(xpos)
   {
      this._x = xpos;
   }
   function get y()
   {
      return this._y;
   }
   function set y(ypos)
   {
      this._y = ypos;
   }
   function createVideoPlayer(index)
   {
      if(_global.isLivePreview)
      {
         return undefined;
      }
      var _loc4_ = this.width;
      var _loc5_ = this.height;
      this._vp[index] = mx.video.VideoPlayer(this.attachMovie("VideoPlayer",String(index),mx.video.FLVPlayback.VP_DEPTH_OFFSET + index));
      this._vp[index].setSize(_loc4_,_loc5_);
      this._topVP = index;
      this._vp[index].autoRewind = this._autoRewind;
      this._vp[index].autoSize = this._autoSize;
      this._vp[index].bufferTime = this._bufferTime;
      this._vp[index].idleTimeout = this._idleTimeout;
      this._vp[index].maintainAspectRatio = this._aspectRatio;
      this._vp[index].playheadUpdateInterval = this._playheadUpdateInterval;
      this._vp[index].progressInterval = this._progressInterval;
      this._vp[index].transform = this._transform;
      this._vp[index].volume = this._volume;
      if(index == 0)
      {
         this._vpState[index] = {id:index,isLive:this._isLive,isLiveSet:true,totalTime:this._totalTime,totalTimeSet:true,autoPlay:this._autoPlay};
         if(this._contentPath != null && this._contentPath != undefined && this._contentPath != "")
         {
            this._vp[index].onEnterFrame = mx.utils.Delegate.create(this,this.doContentPathConnect);
         }
      }
      else
      {
         this._vpState[index] = {id:index,isLive:false,isLiveSet:true,totalTime:0,totalTimeSet:true,autoPlay:false};
      }
      this._vp[index].addEventListener("resize",this);
      this._vp[index].addEventListener("close",this);
      this._vp[index].addEventListener("complete",this);
      this._vp[index].addEventListener("cuePoint",this);
      this._vp[index].addEventListener("playheadUpdate",this);
      this._vp[index].addEventListener("progress",this);
      this._vp[index].addEventListener("metadataReceived",this);
      this._vp[index].addEventListener("stateChange",this);
      this._vp[index].addEventListener("ready",this);
      this._vp[index].addEventListener("rewind",this);
      this._cpMgr[index] = new mx.video.CuePointManager(this,index);
      this._cpMgr[index].playheadUpdateInterval = this._playheadUpdateInterval;
   }
   function createUIManager()
   {
      this._uiMgr = new mx.video.UIManager(this);
      this._uiMgr.visible = false;
      if(this._backButton != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.BACK_BUTTON,this._backButton);
      }
      if(this._bufferingBar != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.BUFFERING_BAR,this._bufferingBar);
      }
      this._uiMgr.bufferingBarHidesAndDisablesOthers = this._bufferingBarHides;
      if(this._forwardButton != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.FORWARD_BUTTON,this._forwardButton);
      }
      if(this._pauseButton != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.PAUSE_BUTTON,this._pauseButton);
      }
      if(this._playButton != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.PLAY_BUTTON,this._playButton);
      }
      if(this._playPauseButton != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.PLAY_PAUSE_BUTTON,this._playPauseButton);
      }
      if(this._stopButton != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.STOP_BUTTON,this._stopButton);
      }
      if(this._seekBar != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.SEEK_BAR,this._seekBar);
      }
      if(this._seekBarInterval != null)
      {
         this._uiMgr.seekBarInterval = this._seekBarInterval;
      }
      if(this._seekBarScrubTolerance != null)
      {
         this._uiMgr.seekBarScrubTolerance = this._seekBarScrubTolerance;
      }
      if(this._skin != null)
      {
         this._uiMgr.skin = this._skin;
      }
      if(this._skinAutoHide != null)
      {
         this._uiMgr.skinAutoHide = this._skinAutoHide;
      }
      if(this._muteButton != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.MUTE_BUTTON,this._muteButton);
      }
      if(this._volumeBar != null)
      {
         this._uiMgr.setControl(mx.video.UIManager.VOLUME_BAR,this._volumeBar);
      }
      if(this._volumeBarInterval != null)
      {
         this._uiMgr.volumeBarInterval = this._volumeBarInterval;
      }
      if(this._volumeBarScrubTolerance != null)
      {
         this._uiMgr.volumeBarScrubTolerance = this._volumeBarScrubTolerance;
      }
   }
   function createLivePreviewMovieClip()
   {
      this.preview_mc = this.createEmptyMovieClip("preview_mc",10);
      this.preview_mc.createEmptyMovieClip("box_mc",10);
      this.preview_mc.box_mc.beginFill(0);
      this.preview_mc.box_mc.moveTo(0,0);
      this.preview_mc.box_mc.lineTo(0,100);
      this.preview_mc.box_mc.lineTo(100,100);
      this.preview_mc.box_mc.lineTo(100,0);
      this.preview_mc.box_mc.lineTo(0,0);
      this.preview_mc.box_mc.endFill();
      this.preview_mc.attachMovie("Icon","icon_mc",20);
   }
   function doContentPathConnect()
   {
      delete this._vp[0].onEnterFrame;
      this._vp[0].onEnterFrame = undefined;
      if(_global.isLivePreview)
      {
         return undefined;
      }
      if(this._vpState[0].autoPlay && this._firstStreamShown)
      {
         this._vp[0].play(this._contentPath,this._isLive,this._totalTime);
      }
      else
      {
         this._vp[0].load(this._contentPath,this._isLive,this._totalTime);
      }
      this._vpState[0].isLiveSet = false;
      this._vpState[0].totalTimeSet = false;
   }
   function showFirstStream()
   {
      this._firstStreamShown = true;
      this._vp[this._visibleVP].visible = true;
      if(!this.scrubbing)
      {
         this._vp[this._visibleVP].volume = this._volume;
      }
      var _loc2_ = 0;
      while(_loc2_ < this._vp.length)
      {
         if(this._vp[_loc2_] != undefined && this._vp[_loc2_].state == mx.video.FLVPlayback.STOPPED && this._vpState[_loc2_].autoPlay)
         {
            this._vp[_loc2_].play();
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function _scrubStart()
   {
      var _loc2_ = this.playheadTime;
      this._vp[this._visibleVP].volume = 0;
      this.dispatchEvent({type:"stateChange",state:mx.video.FLVPlayback.SEEKING,playheadTime:_loc2_,vp:this._visibleVP});
      this.dispatchEvent({type:"scrubStart",state:mx.video.FLVPlayback.SEEKING,playheadTime:_loc2_});
   }
   function _scrubFinish()
   {
      var _loc3_ = this.playheadTime;
      var _loc2_ = this.state;
      this._vp[this._visibleVP].volume = this._volume;
      if(_loc2_ != mx.video.FLVPlayback.SEEKING)
      {
         this.dispatchEvent({type:"stateChange",state:_loc2_,playheadTime:_loc3_,vp:this._visibleVP});
      }
      this.dispatchEvent({type:"scrubFinish",state:_loc2_,playheadTime:_loc3_});
   }
   function skinError(message)
   {
      if(this._firstStreamReady && !this._firstStreamShown)
      {
         this.showFirstStream();
      }
      this.dispatchEvent({type:"skinError",message:message});
   }
   function skinLoaded()
   {
      if(this._firstStreamReady)
      {
         this._uiMgr.visible = true;
         if(!this._firstStreamShown)
         {
            this.showFirstStream();
         }
      }
      else if(this._contentPath == null || this._contentPath == "")
      {
         this._uiMgr.visible = true;
      }
      this.dispatchEvent({type:"skinLoaded"});
   }
}
