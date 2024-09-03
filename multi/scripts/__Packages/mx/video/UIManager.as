class mx.video.UIManager
{
   var _vc;
   var _skin;
   var _skinAutoHide;
   var _skinReady;
   var __visible;
   var _bufferingBarHides;
   var _controlsEnabled;
   var _lastScrubPos;
   var _lastVolumePos;
   var cachedSoundLevel;
   var _isMuted;
   var controls;
   var customClips;
   var skin_mc;
   var skinLoader;
   var layout_mc;
   var border_mc;
   var _seekBarIntervalID;
   var _seekBarInterval;
   var _seekBarScrubTolerance;
   var _volumeBarIntervalID;
   var _volumeBarInterval;
   var _volumeBarScrubTolerance;
   var _bufferingDelayIntervalID;
   var _bufferingDelayInterval;
   var _bufferingOn;
   var _skinAutoHideIntervalID;
   var _progressPercent;
   var uiMgr;
   var state;
   var _focusrect;
   var controlIndex;
   var placeholderLeft;
   var placeholderRight;
   var placeholderTop;
   var placeholderBottom;
   var videoLeft;
   var videoRight;
   var videoTop;
   var videoBottom;
   var _playAfterScrub;
   static var version = "1.0.2.8";
   static var shortVersion = "1.0.2";
   static var PAUSE_BUTTON = 0;
   static var PLAY_BUTTON = 1;
   static var STOP_BUTTON = 2;
   static var SEEK_BAR_HANDLE = 3;
   static var BACK_BUTTON = 4;
   static var FORWARD_BUTTON = 5;
   static var MUTE_ON_BUTTON = 6;
   static var MUTE_OFF_BUTTON = 7;
   static var VOLUME_BAR_HANDLE = 8;
   static var NUM_BUTTONS = 9;
   static var PLAY_PAUSE_BUTTON = 9;
   static var MUTE_BUTTON = 10;
   static var BUFFERING_BAR = 11;
   static var SEEK_BAR = 12;
   static var VOLUME_BAR = 13;
   static var NUM_CONTROLS = 14;
   static var UP_STATE = 0;
   static var OVER_STATE = 1;
   static var DOWN_STATE = 2;
   static var SKIN_AUTO_HIDE_INTERVAL = 200;
   static var VOLUME_BAR_INTERVAL_DEFAULT = 250;
   static var VOLUME_BAR_SCRUB_TOLERANCE_DEFAULT = 0;
   static var SEEK_BAR_INTERVAL_DEFAULT = 250;
   static var SEEK_BAR_SCRUB_TOLERANCE_DEFAULT = 5;
   static var BUFFERING_DELAY_INTERVAL_DEFAULT = 1000;
   function UIManager(vc)
   {
      this._vc = vc;
      this._skin = undefined;
      this._skinAutoHide = false;
      this._skinReady = true;
      this.__visible = true;
      this._bufferingBarHides = false;
      this._controlsEnabled = true;
      this._lastScrubPos = 0;
      this._lastVolumePos = 0;
      this.cachedSoundLevel = this._vc.volume;
      this._isMuted = false;
      this.controls = new Array();
      this.customClips = undefined;
      this.skin_mc = undefined;
      this.skinLoader = undefined;
      this.layout_mc = undefined;
      this.border_mc = undefined;
      this._seekBarIntervalID = 0;
      this._seekBarInterval = mx.video.UIManager.SEEK_BAR_INTERVAL_DEFAULT;
      this._seekBarScrubTolerance = mx.video.UIManager.SEEK_BAR_SCRUB_TOLERANCE_DEFAULT;
      this._volumeBarIntervalID = 0;
      this._volumeBarInterval = mx.video.UIManager.VOLUME_BAR_INTERVAL_DEFAULT;
      this._volumeBarScrubTolerance = mx.video.UIManager.VOLUME_BAR_SCRUB_TOLERANCE_DEFAULT;
      this._bufferingDelayIntervalID = 0;
      this._bufferingDelayInterval = mx.video.UIManager.BUFFERING_DELAY_INTERVAL_DEFAULT;
      this._bufferingOn = false;
      this._skinAutoHideIntervalID = 0;
      this._vc.addEventListener("metadataReceived",this);
      this._vc.addEventListener("playheadUpdate",this);
      this._vc.addEventListener("progress",this);
      this._vc.addEventListener("stateChange",this);
      this._vc.addEventListener("ready",this);
      this._vc.addEventListener("resize",this);
      this._vc.addEventListener("volumeUpdate",this);
   }
   function handleEvent(e)
   {
      if(e.vp != undefined && e.vp != this._vc.visibleVideoPlayerIndex)
      {
         return undefined;
      }
      var _loc9_ = this._vc.activeVideoPlayerIndex;
      this._vc.activeVideoPlayerIndex = this._vc.visibleVideoPlayerIndex;
      if(e.type == "stateChange")
      {
         if(e.state == mx.video.FLVPlayback.BUFFERING)
         {
            if(!this._bufferingOn)
            {
               clearInterval(this._bufferingDelayIntervalID);
               this._bufferingDelayIntervalID = setInterval(this,"doBufferingDelay",this._bufferingDelayInterval);
            }
         }
         else
         {
            clearInterval(this._bufferingDelayIntervalID);
            this._bufferingDelayIntervalID = 0;
            this._bufferingOn = false;
         }
         if(e.state == mx.video.FLVPlayback.LOADING)
         {
            this._progressPercent = !this._vc.getVideoPlayer(e.vp).isRTMP ? 0 : 100;
            var _loc2_ = mx.video.UIManager.SEEK_BAR;
            while(_loc2_ <= mx.video.UIManager.VOLUME_BAR)
            {
               var _loc4_ = this.controls[_loc2_];
               if(_loc4_.progress_mc != undefined)
               {
                  this.positionBar(_loc4_,"progress",this._progressPercent);
               }
               _loc2_ = _loc2_ + 1;
            }
         }
         _loc2_ = 0;
         while(_loc2_ < mx.video.UIManager.NUM_CONTROLS)
         {
            if(this.controls[_loc2_] != undefined)
            {
               this.setEnabledAndVisibleForState(_loc2_,e.state);
               if(_loc2_ < mx.video.UIManager.NUM_BUTTONS)
               {
                  this.skinButtonControl(this.controls[_loc2_]);
               }
            }
            _loc2_ = _loc2_ + 1;
         }
      }
      else if(e.type == "ready" || e.type == "metadataReceived")
      {
         _loc2_ = 0;
         while(_loc2_ < mx.video.UIManager.NUM_CONTROLS)
         {
            if(this.controls[_loc2_] != undefined)
            {
               this.setEnabledAndVisibleForState(_loc2_,this._vc.state);
               if(_loc2_ < mx.video.UIManager.NUM_BUTTONS)
               {
                  this.skinButtonControl(this.controls[_loc2_]);
               }
            }
            _loc2_ = _loc2_ + 1;
         }
         if(this._vc.getVideoPlayer(e.vp).isRTMP)
         {
            this._progressPercent = 100;
            _loc2_ = mx.video.UIManager.SEEK_BAR;
            while(_loc2_ <= mx.video.UIManager.VOLUME_BAR)
            {
               _loc4_ = this.controls[_loc2_];
               if(_loc4_.progress_mc != undefined)
               {
                  this.positionBar(_loc4_,"progress",this._progressPercent);
               }
               _loc2_ = _loc2_ + 1;
            }
         }
      }
      else if(e.type == "resize")
      {
         this.layoutSkin();
         this.setupSkinAutoHide();
      }
      else if(e.type == "volumeUpdate")
      {
         if(this._isMuted && e.volume > 0)
         {
            this._isMuted = false;
            this.setEnabledAndVisibleForState(mx.video.UIManager.MUTE_OFF_BUTTON,mx.video.FLVPlayback.PLAYING);
            this.skinButtonControl(this.controls[mx.video.UIManager.MUTE_OFF_BUTTON]);
            this.setEnabledAndVisibleForState(mx.video.UIManager.MUTE_ON_BUTTON,mx.video.FLVPlayback.PLAYING);
            this.skinButtonControl(this.controls[mx.video.UIManager.MUTE_ON_BUTTON]);
         }
         var _loc5_ = this.controls[mx.video.UIManager.VOLUME_BAR];
         _loc5_.percentage = !this._isMuted ? e.volume : this.cachedSoundLevel;
         if(_loc5_.percentage < 0)
         {
            _loc5_.percentage = 0;
         }
         else if(_loc5_.percentage > 100)
         {
            _loc5_.percentage = 100;
         }
         this.positionHandle(mx.video.UIManager.VOLUME_BAR);
      }
      else if(e.type == "playheadUpdate" && this.controls[mx.video.UIManager.SEEK_BAR] != undefined)
      {
         if(!this._vc.isLive && this._vc.totalTime > 0)
         {
            var _loc6_ = e.playheadTime / this._vc.totalTime * 100;
            if(_loc6_ < 0)
            {
               _loc6_ = 0;
            }
            else if(_loc6_ > 100)
            {
               _loc6_ = 100;
            }
            var _loc10_ = this.controls[mx.video.UIManager.SEEK_BAR];
            _loc10_.percentage = _loc6_;
            this.positionHandle(mx.video.UIManager.SEEK_BAR);
         }
      }
      else if(e.type == "progress")
      {
         this._progressPercent = e.bytesTotal > 0 ? e.bytesLoaded / e.bytesTotal * 100 : 100;
         var _loc7_ = this._vc._vpState[e.vp].minProgressPercent;
         if(!isNaN(_loc7_) && _loc7_ > this._progressPercent)
         {
            this._progressPercent = _loc7_;
         }
         if(this._vc.totalTime > 0)
         {
            var _loc8_ = this._vc.playheadTime / this._vc.totalTime * 100;
            if(_loc8_ > this._progressPercent)
            {
               this._progressPercent = _loc8_;
               this._vc._vpState[e.vp].minProgressPercent = this._progressPercent;
            }
         }
         _loc2_ = mx.video.UIManager.SEEK_BAR;
         while(_loc2_ <= mx.video.UIManager.VOLUME_BAR)
         {
            _loc4_ = this.controls[_loc2_];
            if(_loc4_.progress_mc != undefined)
            {
               this.positionBar(_loc4_,"progress",this._progressPercent);
            }
            _loc2_ = _loc2_ + 1;
         }
      }
      this._vc.activeVideoPlayerIndex = _loc9_;
   }
   function get bufferingBarHidesAndDisablesOthers()
   {
      return this._bufferingBarHides;
   }
   function set bufferingBarHidesAndDisablesOthers(b)
   {
      this._bufferingBarHides = b;
   }
   function get controlsEnabled()
   {
      return this._controlsEnabled;
   }
   function set controlsEnabled(flag)
   {
      if(this._controlsEnabled == flag)
      {
         return;
      }
      this._controlsEnabled = flag;
      var _loc2_ = 0;
      while(_loc2_ < mx.video.UIManager.NUM_BUTTONS)
      {
         if(this.controls[_loc2_] != undefined)
         {
            this.controls[_loc2_].releaseCapture();
            this.controls[_loc2_].enabled = this._controlsEnabled && this.controls[_loc2_].myEnabled;
            this.skinButtonControl(this.controls[_loc2_]);
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function get skin()
   {
      return this._skin;
   }
   function set skin(s)
   {
      if(s == this._skin)
      {
         return;
      }
      if(this._skin != undefined)
      {
         this.removeSkin();
      }
      this._skin = s;
      this._skinReady = this._skin == null || this._skin == "";
      if(!this._skinReady)
      {
         this.downloadSkin();
      }
   }
   function get skinAutoHide()
   {
      return this._skinAutoHide;
   }
   function set skinAutoHide(b)
   {
      if(b == this._skinAutoHide)
      {
         return;
      }
      this._skinAutoHide = b;
      this.setupSkinAutoHide();
   }
   function get skinReady()
   {
      return this._skinReady;
   }
   function get seekBarInterval()
   {
      return this._seekBarInterval;
   }
   function set seekBarInterval(s)
   {
      if(this._seekBarInterval == s)
      {
         return;
      }
      this._seekBarInterval = s;
      if(this._seekBarIntervalID > 0)
      {
         clearInterval(this._seekBarIntervalID);
         this._seekBarIntervalID = setInterval(this,"seekBarListener",this._seekBarInterval,false);
      }
   }
   function get volumeBarInterval()
   {
      return this._volumeBarInterval;
   }
   function set volumeBarInterval(s)
   {
      if(this._volumeBarInterval == s)
      {
         return;
      }
      this._volumeBarInterval = s;
      if(this._volumeBarIntervalID > 0)
      {
         clearInterval(this._volumeBarIntervalID);
         this._volumeBarIntervalID = setInterval(this,"volumeBarListener",this._volumeBarInterval,false);
      }
   }
   function get bufferingDelayInterval()
   {
      return this._bufferingDelayInterval;
   }
   function set bufferingDelayInterval(s)
   {
      if(this._bufferingDelayInterval == s)
      {
         return;
      }
      this._bufferingDelayInterval = s;
      if(this._bufferingDelayIntervalID > 0)
      {
         clearInterval(this._bufferingDelayIntervalID);
         this._bufferingDelayIntervalID = setInterval(this,"doBufferingDelay",this._bufferingDelayIntervalID);
      }
   }
   function get volumeBarScrubTolerance()
   {
      return this._volumeBarScrubTolerance;
   }
   function set volumeBarScrubTolerance(s)
   {
      this._volumeBarScrubTolerance = s;
   }
   function get seekBarScrubTolerance()
   {
      return this._seekBarScrubTolerance;
   }
   function set seekBarScrubTolerance(s)
   {
      this._seekBarScrubTolerance = s;
   }
   function get visible()
   {
      return this.__visible;
   }
   function set visible(v)
   {
      if(this.__visible == v)
      {
         return;
      }
      this.__visible = v;
      if(!this.__visible)
      {
         this.skin_mc._visible = false;
      }
      else
      {
         this.setupSkinAutoHide();
      }
   }
   function getControl(index)
   {
      return this.controls[index];
   }
   function setControl(index, s)
   {
      if(s == null)
      {
         s = undefined;
      }
      if(s == this.controls[index])
      {
         return undefined;
      }
      switch(index)
      {
         case mx.video.UIManager.PAUSE_BUTTON:
         case mx.video.UIManager.PLAY_BUTTON:
            this.resetPlayPause();
            break;
         case mx.video.UIManager.PLAY_PAUSE_BUTTON:
            if(s._parent != this.layout_mc)
            {
               this.resetPlayPause();
               this.setControl(mx.video.UIManager.PAUSE_BUTTON,s.pause_mc);
               this.setControl(mx.video.UIManager.PLAY_BUTTON,s.play_mc);
            }
            break;
         case mx.video.UIManager.MUTE_BUTTON:
            if(s._parent != this.layout_mc)
            {
               this.setControl(mx.video.UIManager.MUTE_ON_BUTTON,s.on_mc);
               this.setControl(mx.video.UIManager.MUTE_OFF_BUTTON,s.off_mc);
            }
      }
      if(index >= mx.video.UIManager.NUM_BUTTONS)
      {
         this.controls[index] = s;
         switch(index)
         {
            case mx.video.UIManager.SEEK_BAR:
               this.addBarControl(mx.video.UIManager.SEEK_BAR);
               break;
            case mx.video.UIManager.VOLUME_BAR:
               this.addBarControl(mx.video.UIManager.VOLUME_BAR);
               this.controls[mx.video.UIManager.VOLUME_BAR].percentage = this._vc.volume;
               break;
            case mx.video.UIManager.BUFFERING_BAR:
               this.controls[mx.video.UIManager.BUFFERING_BAR].uiMgr = this;
               this.controls[mx.video.UIManager.BUFFERING_BAR].controlIndex = mx.video.UIManager.BUFFERING_BAR;
               if(this.controls[mx.video.UIManager.BUFFERING_BAR]._parent == this.skin_mc)
               {
                  this.finishAddBufferingBar();
               }
               else
               {
                  this.controls[mx.video.UIManager.BUFFERING_BAR].onEnterFrame = function()
                  {
                     this.uiMgr.finishAddBufferingBar();
                  };
               }
         }
         this.setEnabledAndVisibleForState(index,this._vc.state);
      }
      else
      {
         this.removeButtonControl(index);
         this.controls[index] = s;
         this.addButtonControl(index);
      }
   }
   function resetPlayPause()
   {
      if(this.controls[mx.video.UIManager.PLAY_PAUSE_BUTTON] == undefined)
      {
         return undefined;
      }
      var _loc2_ = mx.video.UIManager.PAUSE_BUTTON;
      while(_loc2_ <= mx.video.UIManager.PLAY_BUTTON)
      {
         this.removeButtonControl(_loc2_);
         _loc2_ = _loc2_ + 1;
      }
      this.controls[mx.video.UIManager.PLAY_PAUSE_BUTTON] = undefined;
   }
   function addButtonControl(index)
   {
      var _loc3_ = this.controls[index];
      if(_loc3_ == undefined)
      {
         return undefined;
      }
      var _loc5_ = this._vc.activeVideoPlayerIndex;
      this._vc.activeVideoPlayerIndex = this._vc.visibleVideoPlayerIndex;
      _loc3_.id = index;
      _loc3_.state = mx.video.UIManager.UP_STATE;
      _loc3_.uiMgr = this;
      this.setEnabledAndVisibleForState(index,this._vc.state);
      _loc3_.onRollOver = function()
      {
         this.state = mx.video.UIManager.OVER_STATE;
         this.uiMgr.skinButtonControl(this);
      };
      _loc3_.onRollOut = function()
      {
         this.state = mx.video.UIManager.UP_STATE;
         this.uiMgr.skinButtonControl(this);
      };
      if(index == mx.video.UIManager.SEEK_BAR_HANDLE || index == mx.video.UIManager.VOLUME_BAR_HANDLE)
      {
         _loc3_.onPress = function()
         {
            if(_root.focusManager)
            {
               this._focusrect = false;
               Selection.setFocus(this);
            }
            this.state = mx.video.UIManager.DOWN_STATE;
            this.uiMgr.dispatchMessage(this);
            this.uiMgr.skinButtonControl(this);
         };
         _loc3_.onRelease = function()
         {
            this.state = mx.video.UIManager.OVER_STATE;
            this.uiMgr.handleRelease(this.controlIndex);
            this.uiMgr.skinButtonControl(this);
         };
         _loc3_.onReleaseOutside = function()
         {
            this.state = mx.video.UIManager.UP_STATE;
            this.uiMgr.handleRelease(this.controlIndex);
            this.uiMgr.skinButtonControl(this);
         };
      }
      else
      {
         _loc3_.onPress = function()
         {
            if(_root.focusManager)
            {
               this._focusrect = false;
               Selection.setFocus(this);
            }
            this.state = mx.video.UIManager.DOWN_STATE;
            this.uiMgr.skinButtonControl(this);
         };
         _loc3_.onRelease = function()
         {
            this.state = mx.video.UIManager.OVER_STATE;
            this.uiMgr.dispatchMessage(this);
            this.uiMgr.skinButtonControl(this);
         };
         _loc3_.onReleaseOutside = function()
         {
            this.state = mx.video.UIManager.UP_STATE;
            this.uiMgr.skinButtonControl(this);
         };
      }
      if(_loc3_._parent == this.skin_mc)
      {
         this.skinButtonControl(_loc3_);
      }
      else
      {
         _loc3_.onEnterFrame = function()
         {
            this.uiMgr.skinButtonControl(this);
         };
      }
      this._vc.activeVideoPlayerIndex = _loc5_;
   }
   function removeButtonControl(index)
   {
      if(this.controls[index] == undefined)
      {
         return undefined;
      }
      this.controls[index].uiMgr = undefined;
      this.controls[index].onRollOver = undefined;
      this.controls[index].onRollOut = undefined;
      this.controls[index].onPress = undefined;
      this.controls[index].onRelease = undefined;
      this.controls[index].onReleaseOutside = undefined;
      this.controls[index] = undefined;
   }
   function downloadSkin()
   {
      if(this.skinLoader == undefined)
      {
         this.skinLoader = new MovieClipLoader();
         this.skinLoader.addListener(this);
      }
      if(this.skin_mc == undefined)
      {
         this.skin_mc = this._vc.createEmptyMovieClip("skin_mc",this._vc.getNextHighestDepth());
      }
      this.skin_mc._visible = false;
      this.skin_mc._x = Stage.width + 100;
      this.skin_mc._y = Stage.height + 100;
      this.skinLoader.loadClip(this._skin,this.skin_mc);
   }
   function onLoadError(target_mc, errorCode)
   {
      this._skinReady = true;
      this._vc.skinError("Unable to load skin swf");
   }
   function onLoadInit()
   {
      try
      {
         this.skin_mc._visible = false;
         this.skin_mc._x = 0;
         this.skin_mc._y = 0;
         this.layout_mc = this.skin_mc.layout_mc;
         if(this.layout_mc == undefined)
         {
            throw new Error("No layout_mc");
         }
         this.layout_mc._visible = false;
         this.customClips = new Array();
         this.setCustomClips("bg");
         if(this.layout_mc.playpause_mc != undefined)
         {
            this.setSkin(mx.video.UIManager.PLAY_PAUSE_BUTTON,this.layout_mc.playpause_mc);
         }
         else
         {
            this.setSkin(mx.video.UIManager.PAUSE_BUTTON,this.layout_mc.pause_mc);
            this.setSkin(mx.video.UIManager.PLAY_BUTTON,this.layout_mc.play_mc);
         }
         this.setSkin(mx.video.UIManager.STOP_BUTTON,this.layout_mc.stop_mc);
         this.setSkin(mx.video.UIManager.BACK_BUTTON,this.layout_mc.back_mc);
         this.setSkin(mx.video.UIManager.FORWARD_BUTTON,this.layout_mc.forward_mc);
         this.setSkin(mx.video.UIManager.MUTE_BUTTON,this.layout_mc.volumeMute_mc);
         this.setSkin(mx.video.UIManager.SEEK_BAR,this.layout_mc.seekBar_mc);
         this.setSkin(mx.video.UIManager.VOLUME_BAR,this.layout_mc.volumeBar_mc);
         this.setSkin(mx.video.UIManager.BUFFERING_BAR,this.layout_mc.bufferingBar_mc);
         this.setCustomClips("fg");
         this.layoutSkin();
         this.setupSkinAutoHide();
         this.skin_mc._visible = this.__visible;
         this._skinReady = true;
         this._vc.skinLoaded();
         var _loc4_ = this._vc.activeVideoPlayerIndex;
         this._vc.activeVideoPlayerIndex = this._vc.visibleVideoPlayerIndex;
         var _loc3_ = this._vc.state;
         var _loc2_ = 0;
         while(_loc2_ < mx.video.UIManager.NUM_CONTROLS)
         {
            if(this.controls[_loc2_] != undefined)
            {
               this.setEnabledAndVisibleForState(_loc2_,_loc3_);
               if(_loc2_ < mx.video.UIManager.NUM_BUTTONS)
               {
                  this.skinButtonControl(this.controls[_loc2_]);
               }
            }
            _loc2_ = _loc2_ + 1;
         }
         this._vc.activeVideoPlayerIndex = _loc4_;
      }
      catch(err:Error)
      {
         this._vc.skinError(err.message);
         this.removeSkin();
      }
   }
   function layoutSkin()
   {
      if(this.layout_mc == undefined)
      {
         return undefined;
      }
      var _loc3_ = this.layout_mc.video_mc;
      if(_loc3_ == undefined)
      {
         throw new Error("No layout_mc.video_mc");
      }
      this.placeholderLeft = _loc3_._x;
      this.placeholderRight = _loc3_._x + _loc3_._width;
      this.placeholderTop = _loc3_._y;
      this.placeholderBottom = _loc3_._y + _loc3_._height;
      this.videoLeft = 0;
      this.videoRight = this._vc.width;
      this.videoTop = 0;
      this.videoBottom = this._vc.height;
      if(!isNaN(this.layout_mc.minWidth) && this.layout_mc.minWidth > 0 && this.layout_mc.minWidth > this.videoRight)
      {
         this.videoLeft -= (this.layout_mc.minWidth - this.videoRight) / 2;
         this.videoRight = this.layout_mc.minWidth + this.videoLeft;
      }
      if(!isNaN(this.layout_mc.minHeight) && this.layout_mc.minHeight > 0 && this.layout_mc.minHeight > this.videoBottom)
      {
         this.videoTop -= (this.layout_mc.minHeight - this.videoBottom) / 2;
         this.videoBottom = this.layout_mc.minHeight + this.videoTop;
      }
      var _loc2_ = undefined;
      _loc2_ = 0;
      while(_loc2_ < this.customClips.length)
      {
         this.layoutControl(this.customClips[_loc2_]);
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < mx.video.UIManager.NUM_CONTROLS)
      {
         this.layoutControl(this.controls[_loc2_]);
         _loc2_ = _loc2_ + 1;
      }
   }
   function layoutControl(ctrl)
   {
      if(ctrl == undefined)
      {
         return undefined;
      }
      if(ctrl.skin.anchorRight)
      {
         if(ctrl.skin.anchorLeft)
         {
            ctrl._x = ctrl.skin._x - this.placeholderLeft + this.videoLeft;
            ctrl._width = ctrl.skin._x + ctrl.skin._width - this.placeholderRight + this.videoRight - ctrl._x;
            if(ctrl.origWidth != undefined)
            {
               ctrl.origWidth = undefined;
            }
         }
         else
         {
            ctrl._x = ctrl.skin._x - this.placeholderRight + this.videoRight;
         }
      }
      else
      {
         ctrl._x = ctrl.skin._x - this.placeholderLeft + this.videoLeft;
      }
      if(ctrl.skin.anchorTop)
      {
         if(ctrl.skin.anchorBottom)
         {
            ctrl._y = ctrl.skin._y - this.placeholderTop + this.videoTop;
            ctrl._height = ctrl.skin._y + ctrl.skin._height - this.placeholderBottom + this.videoBottom - ctrl._y;
            if(ctrl.origHeight != undefined)
            {
               ctrl.origHeight = undefined;
            }
         }
         else
         {
            ctrl._y = ctrl.skin._y - this.placeholderTop + this.videoTop;
         }
      }
      else
      {
         ctrl._y = ctrl.skin._y - this.placeholderBottom + this.videoBottom;
      }
      switch(ctrl.controlIndex)
      {
         case mx.video.UIManager.SEEK_BAR:
         case mx.video.UIManager.VOLUME_BAR:
            if(ctrl.progress_mc != undefined)
            {
               if(this._progressPercent == undefined)
               {
                  this._progressPercent = !this._vc.isRTMP ? 0 : 100;
               }
               this.positionBar(ctrl,"progress",this._progressPercent);
            }
            this.positionHandle(ctrl.controlIndex);
            break;
         case mx.video.UIManager.BUFFERING_BAR:
            if(ctrl.fill_mc != undefined)
            {
               this.positionMaskedFill(ctrl,ctrl.fill_mc,100);
            }
      }
      if(ctrl.layoutSelf != undefined)
      {
         ctrl.layoutSelf();
      }
   }
   function removeSkin()
   {
      if(this.skin_mc != undefined)
      {
         var _loc2_ = 0;
         while(_loc2_ < mx.video.UIManager.NUM_BUTTONS)
         {
            this.removeButtonControl(_loc2_);
            _loc2_ = _loc2_ + 1;
         }
         _loc2_ = mx.video.UIManager.NUM_BUTTONS;
         while(_loc2_ < mx.video.UIManager.NUM_CONTROLS)
         {
            this.controls[_loc2_] = undefined;
            _loc2_ = _loc2_ + 1;
         }
         this.skin_mc.unloadMovie();
         this.layout_mc = undefined;
         this.border_mc = undefined;
      }
   }
   function setCustomClips(prefix)
   {
      var _loc4_ = 1;
      while(true)
      {
         var _loc2_ = this.layout_mc[prefix + _loc4_++ + "_mc"];
         if(_loc2_ == undefined)
         {
            break;
         }
         var _loc3_ = _loc2_.mc;
         if(_loc3_ == undefined)
         {
            _loc3_ = _loc2_._parent._parent[_loc2_._name];
         }
         if(_loc3_ == undefined)
         {
            throw new Error("Bad clip in skin: " + _loc2_);
         }
         _loc3_.skin = _loc2_;
         this.customClips.push(_loc3_);
         if(prefix == "bg" && _loc4_ == 2)
         {
            this.border_mc = _loc3_;
         }
      }
   }
   function setSkin(index, s)
   {
      if(s == undefined)
      {
         return undefined;
      }
      var _loc2_ = s.mc;
      if(_loc2_ == undefined)
      {
         _loc2_ = s._parent._parent[s._name];
      }
      if(_loc2_ == undefined)
      {
         throw new Error("Bad clip in skin: " + s);
      }
      _loc2_.skin = s;
      if(index < mx.video.UIManager.NUM_BUTTONS)
      {
         this.setupSkinStates(_loc2_);
      }
      else
      {
         switch(index)
         {
            case mx.video.UIManager.PLAY_PAUSE_BUTTON:
               this.setupSkinStates(_loc2_.play_mc);
               this.setupSkinStates(_loc2_.pause_mc);
               break;
            case mx.video.UIManager.MUTE_BUTTON:
               this.setupSkinStates(_loc2_.on_mc);
               this.setupSkinStates(_loc2_.off_mc);
               break;
            case mx.video.UIManager.SEEK_BAR:
            case mx.video.UIManager.VOLUME_BAR:
               var _loc4_ = index != mx.video.UIManager.SEEK_BAR ? "volumeBar" : "seekBar";
               if(_loc2_.handle_mc == undefined)
               {
                  _loc2_.handle_mc = _loc2_.skin.handle_mc;
                  if(_loc2_.handle_mc == undefined)
                  {
                     _loc2_.handle_mc = _loc2_.skin._parent._parent[_loc4_ + "Handle_mc"];
                  }
               }
               if(_loc2_.progress_mc == undefined)
               {
                  _loc2_.progress_mc = _loc2_.skin.progress_mc;
                  if(_loc2_.progress_mc == undefined)
                  {
                     _loc2_.progress_mc = _loc2_.skin._parent._parent[_loc4_ + "Progress_mc"];
                  }
               }
               if(_loc2_.fullness_mc == undefined)
               {
                  _loc2_.fullness_mc = _loc2_.skin.fullness_mc;
                  if(_loc2_.fullness_mc == undefined)
                  {
                     _loc2_.fullness_mc = _loc2_.skin._parent._parent[_loc4_ + "Fullness_mc"];
                  }
               }
               break;
            case mx.video.UIManager.BUFFERING_BAR:
               if(_loc2_.fill_mc == undefined)
               {
                  _loc2_.fill_mc = _loc2_.skin.fill_mc;
                  if(_loc2_.fill_mc == undefined)
                  {
                     _loc2_.fill_mc = _loc2_.skin._parent._parent.bufferingBarFill_mc;
                  }
               }
         }
      }
      this.setControl(index,_loc2_);
   }
   function setupSkinStates(ctrl)
   {
      if(ctrl.up_mc == undefined)
      {
         ctrl.up_mc = ctrl;
         ctrl.over_mc = ctrl;
         ctrl.down_mc = ctrl;
         ctrl.disabled_mc = ctrl;
      }
      else
      {
         ctrl._x = 0;
         ctrl._y = 0;
         ctrl.up_mc._x = 0;
         ctrl.up_mc._y = 0;
         ctrl.up_mc._visible = true;
         if(ctrl.over_mc == undefined)
         {
            ctrl.over_mc = ctrl.up_mc;
         }
         else
         {
            ctrl.over_mc._x = 0;
            ctrl.over_mc._y = 0;
            ctrl.over_mc._visible = false;
         }
         if(ctrl.down_mc == undefined)
         {
            ctrl.down_mc = ctrl.up_mc;
         }
         else
         {
            ctrl.down_mc._x = 0;
            ctrl.down_mc._y = 0;
            ctrl.down_mc._visible = false;
         }
         if(ctrl.disabled_mc == undefined)
         {
            ctrl.disabled_mc_mc = ctrl.up_mc;
         }
         else
         {
            ctrl.disabled_mc._x = 0;
            ctrl.disabled_mc._y = 0;
            ctrl.disabled_mc._visible = false;
         }
      }
   }
   function skinButtonControl(ctrl)
   {
      if(ctrl.onEnterFrame != undefined)
      {
         delete ctrl.onEnterFrame;
         ctrl.onEnterFrame = undefined;
      }
      if(ctrl.enabled)
      {
         switch(ctrl.state)
         {
            case mx.video.UIManager.UP_STATE:
               if(ctrl.up_mc == undefined)
               {
                  ctrl.up_mc = ctrl.attachMovie(ctrl.upLinkageID,"up_mc",ctrl.getNextHighestDepth());
               }
               this.applySkinState(ctrl,ctrl.up_mc);
               break;
            case mx.video.UIManager.OVER_STATE:
               if(ctrl.over_mc == undefined)
               {
                  if(ctrl.overLinkageID == undefined)
                  {
                     ctrl.over_mc = ctrl.up_mc;
                  }
                  else
                  {
                     ctrl.over_mc = ctrl.attachMovie(ctrl.overLinkageID,"over_mc",ctrl.getNextHighestDepth());
                  }
               }
               this.applySkinState(ctrl,ctrl.over_mc);
               break;
            case mx.video.UIManager.DOWN_STATE:
               if(ctrl.down_mc == undefined)
               {
                  if(ctrl.downLinkageID == undefined)
                  {
                     ctrl.down_mc = ctrl.up_mc;
                  }
                  else
                  {
                     ctrl.down_mc = ctrl.attachMovie(ctrl.downLinkageID,"down_mc",ctrl.getNextHighestDepth());
                  }
               }
               this.applySkinState(ctrl,ctrl.down_mc);
         }
      }
      else
      {
         ctrl.state = mx.video.UIManager.UP_STATE;
         if(ctrl.disabled_mc == undefined)
         {
            if(ctrl.disabledLinkageID == undefined)
            {
               ctrl.disabled_mc = ctrl.up_mc;
            }
            else
            {
               ctrl.disabled_mc = ctrl.attachMovie(ctrl.disabledLinkageID,"disabled_mc",ctrl.getNextHighestDepth());
            }
         }
         this.applySkinState(ctrl,ctrl.disabled_mc);
      }
      if(ctrl.placeholder_mc != undefined)
      {
         ctrl.placeholder_mc.unloadMovie();
         delete ctrl.placeholder_mc;
         ctrl.placeholder_mc = undefined;
      }
   }
   function applySkinState(ctrl, state)
   {
      if(state != ctrl.currentState_mc)
      {
         if(state != undefined)
         {
            state._visible = true;
         }
         if(ctrl.currentState_mc != undefined)
         {
            ctrl.currentState_mc._visible = false;
         }
         ctrl.currentState_mc = state;
      }
   }
   function addBarControl(controlIndex)
   {
      var _loc2_ = this.controls[controlIndex];
      _loc2_.isDragging = false;
      _loc2_.percentage = 0;
      _loc2_.uiMgr = this;
      _loc2_.controlIndex = controlIndex;
      if(_loc2_._parent == this.skin_mc)
      {
         this.finishAddBarControl(controlIndex);
      }
      else
      {
         _loc2_.onEnterFrame = function()
         {
            this.uiMgr.finishAddBarControl(this.controlIndex);
         };
      }
   }
   function finishAddBarControl(controlIndex)
   {
      var _loc2_ = this.controls[controlIndex];
      delete _loc2_.onEnterFrame;
      _loc2_.onEnterFrame = undefined;
      if(_loc2_.addBarControl != undefined)
      {
         _loc2_.addBarControl();
      }
      this.calcBarMargins(_loc2_,"handle",true);
      this.calcBarMargins(_loc2_,"progress",false);
      this.calcBarMargins(_loc2_.progress_mc,"fill",false);
      this.calcBarMargins(_loc2_.progress_mc,"mask",false);
      this.calcBarMargins(_loc2_,"fullness",false);
      this.calcBarMargins(_loc2_.fullness_mc,"fill",false);
      this.calcBarMargins(_loc2_.fullness_mc,"mask",false);
      _loc2_.origWidth = _loc2_._width;
      _loc2_.origHeight = _loc2_._height;
      this.fixUpBar(_loc2_,"progress");
      if(_loc2_.progress_mc != undefined)
      {
         this.fixUpBar(_loc2_,"progressBarFill");
         if(this._progressPercent == undefined)
         {
            this._progressPercent = !this._vc.isRTMP ? 0 : 100;
         }
         this.positionBar(_loc2_,"progress",this._progressPercent);
      }
      this.fixUpBar(_loc2_,"fullness");
      if(_loc2_.fullness_mc != undefined)
      {
         this.fixUpBar(_loc2_,"fullnessBarFill");
      }
      this.fixUpBar(_loc2_,"handle");
      _loc2_.handle_mc.controlIndex = controlIndex;
      switch(controlIndex)
      {
         case mx.video.UIManager.SEEK_BAR:
            this.setControl(mx.video.UIManager.SEEK_BAR_HANDLE,_loc2_.handle_mc);
            break;
         case mx.video.UIManager.VOLUME_BAR:
            this.setControl(mx.video.UIManager.VOLUME_BAR_HANDLE,_loc2_.handle_mc);
      }
      this.positionHandle(controlIndex);
   }
   function fixUpBar(ctrl, type)
   {
      if(ctrl[type + "LinkageID"] != undefined && ctrl[type + "LinkageID"].length > 0)
      {
         var _loc1_ = undefined;
         if(ctrl[type + "Below"])
         {
            _loc1_ = -1;
            while(ctrl._parent.getInstanceAtDepth(_loc1_) != undefined)
            {
               _loc1_ = _loc1_ - 1;
            }
         }
         else
         {
            ctrl[type + "Below"] = false;
            _loc1_ = ctrl._parent.getNextHighestDepth();
         }
         var _loc5_ = ctrl.controlIndex != mx.video.UIManager.SEEK_BAR ? "volumeBar" : "seekBar";
         var _loc4_ = _loc5_ + type.substring(0,1).toUpperCase() + type.substring(1) + "_mc";
         ctrl[type + "_mc"] = ctrl._parent.attachMovie(ctrl[type + "LinkageID"],_loc4_,_loc1_);
      }
   }
   function calcBarMargins(ctrl, type, symmetricMargins)
   {
      var _loc2_ = ctrl[type + "_mc"];
      if(_loc2_ == undefined)
      {
         return undefined;
      }
      if(ctrl[type + "LeftMargin"] == undefined && _loc2_._parent == ctrl._parent)
      {
         ctrl[type + "LeftMargin"] = _loc2_._x - ctrl._x;
      }
      if(ctrl[type + "RightMargin"] == undefined)
      {
         if(symmetricMargins)
         {
            ctrl[type + "RightMargin"] = ctrl[type + "LeftMargin"];
         }
         else if(_loc2_._parent == ctrl._parent)
         {
            ctrl[type + "RightMargin"] = ctrl._width - _loc2_._width - _loc2_._x + ctrl._x;
         }
      }
      if(ctrl[type + "TopMargin"] == undefined && _loc2_._parent == ctrl._parent)
      {
         ctrl[type + "TopMargin"] = _loc2_._y - ctrl._y;
      }
      if(ctrl[type + "BottomMargin"] == undefined)
      {
         if(symmetricMargins)
         {
            ctrl[type + "BottomMargin"] = ctrl[type + "TopMargin"];
         }
         else if(_loc2_._parent == ctrl._parent)
         {
            ctrl[type + "BottomMargin"] = ctrl._height - _loc2_._height - _loc2_._y + ctrl._y;
         }
      }
      if(ctrl[type + "X"] == undefined)
      {
         if(_loc2_._parent == ctrl._parent)
         {
            ctrl[type + "X"] = _loc2_._x - ctrl._x;
         }
         else if(_loc2_._parent == ctrl)
         {
            ctrl[type + "X"] = _loc2_._x;
         }
      }
      if(ctrl[type + "Y"] == undefined)
      {
         if(_loc2_._parent == ctrl._parent)
         {
            ctrl[type + "Y"] = _loc2_._y - ctrl._y;
         }
         else if(_loc2_._parent == ctrl)
         {
            ctrl[type + "Y"] = _loc2_._y;
         }
      }
      ctrl[type + "XScale"] = _loc2_._xscale;
      ctrl[type + "YScale"] = _loc2_._yscale;
      ctrl[type + "Width"] = _loc2_._width;
      ctrl[type + "Height"] = _loc2_._height;
   }
   function finishAddBufferingBar()
   {
      var _loc2_ = this.controls[mx.video.UIManager.BUFFERING_BAR];
      delete _loc2_.onEnterFrame;
      _loc2_.onEnterFrame = undefined;
      this.calcBarMargins(_loc2_,"fill",true);
      this.fixUpBar(_loc2_,"fill");
      if(_loc2_.fill_mc != undefined)
      {
         this.positionMaskedFill(_loc2_,_loc2_.fill_mc,100);
      }
   }
   function positionMaskedFill(ctrl, fill, percent)
   {
      var _loc5_ = fill._parent;
      var _loc3_ = ctrl.mask_mc;
      if(_loc3_ == undefined)
      {
         _loc3_ = _loc5_.createEmptyMovieClip(ctrl._name + "Mask_mc",_loc5_.getNextHighestDepth());
         ctrl.mask_mc = _loc3_;
         _loc3_.beginFill(16777215);
         _loc3_.lineTo(0,0);
         _loc3_.lineTo(1,0);
         _loc3_.lineTo(1,1);
         _loc3_.lineTo(0,1);
         _loc3_.lineTo(0,0);
         _loc3_.endFill();
         fill.setMask(_loc3_);
         _loc3_._x = ctrl.fillX;
         _loc3_._y = ctrl.fillY;
         _loc3_._width = ctrl.fillWidth;
         _loc3_._height = ctrl.fillHeight;
         _loc3_._visible = false;
         this.calcBarMargins(ctrl,"mask",true);
      }
      if(_loc5_ == ctrl)
      {
         if(fill.slideReveal)
         {
            fill._x = ctrl.maskX - ctrl.fillWidth + ctrl.fillWidth * percent / 100;
         }
         else
         {
            _loc3_._width = ctrl.fillWidth * percent / 100;
         }
      }
      else if(_loc5_ == ctrl._parent)
      {
         if(fill.slideReveal)
         {
            _loc3_._x = ctrl._x + ctrl.maskLeftMargin;
            _loc3_._y = ctrl._y + ctrl.maskTopMargin;
            _loc3_._width = ctrl._width - ctrl.maskRightMargin - ctrl.maskLeftMargin;
            _loc3_._height = ctrl._height - ctrl.maskTopMargin - ctrl.maskBottomMargin;
            fill._x = _loc3_._x - ctrl.fillWidth + ctrl.maskWidth * percent / 100;
            fill._y = ctrl._y + ctrl.fillTopMargin;
         }
         else
         {
            fill._x = ctrl._x + ctrl.fillLeftMargin;
            fill._y = ctrl._y + ctrl.fillTopMargin;
            _loc3_._x = fill._x;
            _loc3_._y = fill._y;
            _loc3_._width = (ctrl._width - ctrl.fillRightMargin - ctrl.fillLeftMargin) * percent / 100;
            _loc3_._height = ctrl._height - ctrl.fillTopMargin - ctrl.fillBottomMargin;
         }
      }
   }
   function startHandleDrag(controlIndex)
   {
      var _loc2_ = this.controls[controlIndex];
      var _loc5_ = _loc2_.handle_mc;
      if(_loc2_.startHandleDrag == undefined || !_loc2_.startHandleDrag())
      {
         var _loc3_ = _loc2_._y + _loc2_.handleY;
         var _loc4_ = _loc2_.origWidth != undefined ? _loc2_.origWidth : _loc2_._width;
         _loc5_.startDrag(false,_loc2_._x + _loc2_.handleLeftMargin,_loc3_,_loc2_._x + _loc4_ - _loc2_.handleRightMargin,_loc3_);
      }
      _loc2_.isDragging = true;
   }
   function stopHandleDrag(controlIndex)
   {
      var _loc2_ = this.controls[controlIndex];
      var _loc3_ = _loc2_.handle_mc;
      if(_loc2_.stopHandleDrag == undefined || !_loc2_.stopHandleDrag())
      {
         _loc3_.stopDrag();
      }
      _loc2_.isDragging = false;
   }
   function positionHandle(controlIndex)
   {
      var _loc2_ = this.controls[controlIndex];
      var _loc3_ = _loc2_.handle_mc;
      if(_loc3_ == undefined)
      {
         return undefined;
      }
      if(_loc2_.positionHandle != undefined && _loc2_.positionHandle())
      {
         return undefined;
      }
      var _loc4_ = _loc2_.origWidth != undefined ? _loc2_.origWidth : _loc2_._width;
      var _loc5_ = _loc4_ - _loc2_.handleRightMargin - _loc2_.handleLeftMargin;
      _loc3_._x = _loc2_._x + _loc2_.handleLeftMargin + _loc5_ * _loc2_.percentage / 100;
      _loc3_._y = _loc2_._y + _loc2_.handleY;
      if(_loc2_.fullness_mc != undefined)
      {
         this.positionBar(_loc2_,"fullness",_loc2_.percentage);
      }
   }
   function positionBar(ctrl, type, percent)
   {
      if(ctrl.positionBar != undefined && ctrl.positionBar(type,percent))
      {
         return undefined;
      }
      var _loc2_ = ctrl[type + "_mc"];
      if(_loc2_._parent == ctrl)
      {
         if(_loc2_.fill_mc == undefined)
         {
            _loc2_._xscale = ctrl[type + "XScale"] * percent / 100;
         }
         else
         {
            this.positionMaskedFill(_loc2_,_loc2_.fill_mc,percent);
         }
      }
      else
      {
         _loc2_._x = ctrl._x + ctrl[type + "LeftMargin"];
         _loc2_._y = ctrl._y + ctrl[type + "Y"];
         if(_loc2_.fill_mc == undefined)
         {
            _loc2_._width = (ctrl._width - ctrl[type + "LeftMargin"] - ctrl[type + "RightMargin"]) * percent / 100;
         }
         else
         {
            this.positionMaskedFill(_loc2_,_loc2_.fill_mc,percent);
         }
      }
   }
   function calcPercentageFromHandle(controlIndex)
   {
      var _loc2_ = this.controls[controlIndex];
      var _loc5_ = _loc2_.handle_mc;
      if(_loc2_.calcPercentageFromHandle == undefined || !_loc2_.calcPercentageFromHandle())
      {
         var _loc3_ = _loc2_.origWidth != undefined ? _loc2_.origWidth : _loc2_._width;
         var _loc6_ = _loc3_ - _loc2_.handleRightMargin - _loc2_.handleLeftMargin;
         var _loc4_ = _loc5_._x - (_loc2_._x + _loc2_.handleLeftMargin);
         _loc2_.percentage = _loc4_ / _loc6_ * 100;
         if(_loc2_.fullness_mc != undefined)
         {
            this.positionBar(_loc2_,"fullness",_loc2_.percentage);
         }
      }
      if(_loc2_.percentage < 0)
      {
         _loc2_.percentage = 0;
      }
      if(_loc2_.percentage > 100)
      {
         _loc2_.percentage = 100;
      }
   }
   function handleRelease(controlIndex)
   {
      var _loc3_ = this._vc.activeVideoPlayerIndex;
      this._vc.activeVideoPlayerIndex = this._vc.visibleVideoPlayerIndex;
      if(controlIndex == mx.video.UIManager.SEEK_BAR)
      {
         this.seekBarListener(true);
      }
      else if(controlIndex == mx.video.UIManager.VOLUME_BAR)
      {
         this.volumeBarListener(true);
      }
      this.stopHandleDrag(controlIndex);
      this._vc.activeVideoPlayerIndex = _loc3_;
      if(controlIndex == mx.video.UIManager.SEEK_BAR)
      {
         this._vc._scrubFinish();
      }
   }
   function seekBarListener(finish)
   {
      var _loc3_ = this._vc.activeVideoPlayerIndex;
      this._vc.activeVideoPlayerIndex = this._vc.visibleVideoPlayerIndex;
      var _loc4_ = this.controls[mx.video.UIManager.SEEK_BAR];
      this.calcPercentageFromHandle(mx.video.UIManager.SEEK_BAR);
      var _loc2_ = _loc4_.percentage;
      if(finish)
      {
         clearInterval(this._seekBarIntervalID);
         this._seekBarIntervalID = 0;
         if(_loc2_ != this._lastScrubPos)
         {
            this._vc.seekPercent(_loc2_);
         }
         this._vc.addEventListener("playheadUpdate",this);
         if(this._playAfterScrub)
         {
            this._vc.play();
         }
      }
      else if(this._vc.getVideoPlayer(this._vc.visibleVideoPlayerIndex).state != mx.video.VideoPlayer.SEEKING)
      {
         if(this._seekBarScrubTolerance <= 0 || Math.abs(_loc2_ - this._lastScrubPos) > this._seekBarScrubTolerance || _loc2_ < this._seekBarScrubTolerance || _loc2_ > 100 - this._seekBarScrubTolerance)
         {
            if(_loc2_ != this._lastScrubPos)
            {
               this._lastScrubPos = _loc2_;
               this._vc.seekPercent(_loc2_);
            }
         }
      }
      this._vc.activeVideoPlayerIndex = _loc3_;
   }
   function volumeBarListener(finish)
   {
      var _loc3_ = this.controls[mx.video.UIManager.VOLUME_BAR];
      this.calcPercentageFromHandle(mx.video.UIManager.VOLUME_BAR);
      var _loc2_ = _loc3_.percentage;
      if(finish)
      {
         clearInterval(this._volumeBarIntervalID);
         this._volumeBarIntervalID = 0;
         this._vc.addEventListener("volumeUpdate",this);
      }
      if(finish || this._volumeBarScrubTolerance <= 0 || Math.abs(_loc2_ - this._lastVolumePos) > this._volumeBarScrubTolerance || _loc2_ < this._volumeBarScrubTolerance || _loc2_ > 100 - this._volumeBarScrubTolerance)
      {
         if(_loc2_ != this._lastVolumePos)
         {
            if(this._isMuted)
            {
               this.cachedSoundLevel = _loc2_;
            }
            else
            {
               this._vc.volume = _loc2_;
            }
            this._lastVolumePos = _loc2_;
         }
      }
   }
   function doBufferingDelay()
   {
      clearInterval(this._bufferingDelayIntervalID);
      this._bufferingDelayIntervalID = 0;
      var _loc2_ = this._vc.activeVideoPlayerIndex;
      this._vc.activeVideoPlayerIndex = this._vc.visibleVideoPlayerIndex;
      if(this._vc.state == mx.video.FLVPlayback.BUFFERING)
      {
         this._bufferingOn = true;
         this.handleEvent({type:"stateChange",state:mx.video.FLVPlayback.BUFFERING,vp:this._vc.visibleVideoPlayerIndex});
      }
      this._vc.activeVideoPlayerIndex = _loc2_;
   }
   function dispatchMessage(ctrl)
   {
      if(ctrl.id == mx.video.UIManager.SEEK_BAR_HANDLE)
      {
         this._vc._scrubStart();
      }
      var _loc2_ = this._vc.activeVideoPlayerIndex;
      this._vc.activeVideoPlayerIndex = this._vc.visibleVideoPlayerIndex;
      switch(ctrl.id)
      {
         case mx.video.UIManager.PAUSE_BUTTON:
            this._vc.pause();
            break;
         case mx.video.UIManager.PLAY_BUTTON:
            this._vc.play();
            break;
         case mx.video.UIManager.STOP_BUTTON:
            this._vc.stop();
            break;
         case mx.video.UIManager.SEEK_BAR_HANDLE:
            this.calcPercentageFromHandle(mx.video.UIManager.SEEK_BAR);
            this._lastScrubPos = this.controls[mx.video.UIManager.SEEK_BAR].percentage;
            this._vc.removeEventListener("playheadUpdate",this);
            if(this._vc.playing || this._vc.buffering)
            {
               this._playAfterScrub = true;
            }
            else if(this._vc.state != mx.video.VideoPlayer.SEEKING)
            {
               this._playAfterScrub = false;
            }
            this._seekBarIntervalID = setInterval(this,"seekBarListener",this._seekBarInterval,false);
            this.startHandleDrag(mx.video.UIManager.SEEK_BAR);
            this._vc.pause();
            break;
         case mx.video.UIManager.VOLUME_BAR_HANDLE:
            this.calcPercentageFromHandle(mx.video.UIManager.VOLUME_BAR);
            this._lastVolumePos = this.controls[mx.video.UIManager.VOLUME_BAR].percentage;
            this._vc.removeEventListener("volumeUpdate",this);
            this._volumeBarIntervalID = setInterval(this,"volumeBarListener",this._volumeBarInterval,false);
            this.startHandleDrag(mx.video.UIManager.VOLUME_BAR);
            break;
         case mx.video.UIManager.BACK_BUTTON:
            this._vc.seekToPrevNavCuePoint();
            break;
         case mx.video.UIManager.FORWARD_BUTTON:
            this._vc.seekToNextNavCuePoint();
            break;
         case mx.video.UIManager.MUTE_ON_BUTTON:
         case mx.video.UIManager.MUTE_OFF_BUTTON:
            if(!this._isMuted)
            {
               this._isMuted = true;
               this.cachedSoundLevel = this._vc.volume;
               this._vc.volume = 0;
            }
            else
            {
               this._isMuted = false;
               this._vc.volume = this.cachedSoundLevel;
            }
            this.setEnabledAndVisibleForState(mx.video.UIManager.MUTE_OFF_BUTTON,mx.video.FLVPlayback.PLAYING);
            this.skinButtonControl(this.controls[mx.video.UIManager.MUTE_OFF_BUTTON]);
            this.setEnabledAndVisibleForState(mx.video.UIManager.MUTE_ON_BUTTON,mx.video.FLVPlayback.PLAYING);
            this.skinButtonControl(this.controls[mx.video.UIManager.MUTE_ON_BUTTON]);
            break;
         default:
            throw new Error("Unknown ButtonControl");
      }
      this._vc.activeVideoPlayerIndex = _loc2_;
   }
   function setEnabledAndVisibleForState(index, state)
   {
      var _loc5_ = this._vc.activeVideoPlayerIndex;
      this._vc.activeVideoPlayerIndex = this._vc.visibleVideoPlayerIndex;
      var _loc3_ = state;
      if(_loc3_ == mx.video.FLVPlayback.BUFFERING && !this._bufferingOn)
      {
         _loc3_ = mx.video.FLVPlayback.PLAYING;
      }
      switch(index)
      {
         case mx.video.UIManager.VOLUME_BAR:
         case mx.video.UIManager.VOLUME_BAR_HANDLE:
            this.controls[index].myEnabled = true;
            this.controls[index].enabled = this._controlsEnabled;
            break;
         case mx.video.UIManager.MUTE_ON_BUTTON:
            this.controls[index].myEnabled = !this._isMuted;
            if(this.controls[mx.video.UIManager.MUTE_BUTTON] != undefined)
            {
               this.controls[index]._visible = this.controls[index].myEnabled;
            }
            break;
         case mx.video.UIManager.MUTE_OFF_BUTTON:
            this.controls[index].myEnabled = this._isMuted;
            if(this.controls[mx.video.UIManager.MUTE_BUTTON] != undefined)
            {
               this.controls[index]._visible = this.controls[index].myEnabled;
            }
            break;
         default:
            switch(_loc3_)
            {
               case mx.video.FLVPlayback.LOADING:
               case mx.video.FLVPlayback.CONNECTION_ERROR:
                  this.controls[index].myEnabled = false;
                  break;
               case mx.video.FLVPlayback.DISCONNECTED:
                  this.controls[index].myEnabled = this._vc.contentPath != undefined;
                  break;
               case mx.video.FLVPlayback.SEEKING:
                  break;
               default:
                  this.controls[index].myEnabled = true;
            }
      }
      switch(index)
      {
         case mx.video.UIManager.SEEK_BAR:
            switch(_loc3_)
            {
               case mx.video.FLVPlayback.STOPPED:
               case mx.video.FLVPlayback.PLAYING:
               case mx.video.FLVPlayback.PAUSED:
               case mx.video.FLVPlayback.REWINDING:
               case mx.video.FLVPlayback.SEEKING:
                  this.controls[index].myEnabled = true;
                  break;
               case mx.video.FLVPlayback.BUFFERING:
                  this.controls[index].myEnabled = !this._bufferingBarHides || this.controls[mx.video.UIManager.BUFFERING_BAR] == undefined;
                  break;
               default:
                  this.controls[index].myEnabled = false;
            }
            if(this.controls[index].myEnabled)
            {
               this.controls[index].myEnabled = !isNaN(this._vc.totalTime) && this._vc.totalTime > 0;
            }
            this.controls[index].handle_mc.myEnabled = this.controls[index].myEnabled;
            this.controls[index].handle_mc.enabled = this.controls[index].handle_mc.myEnabled;
            this.controls[index].handle_mc._visible = this.controls[index].myEnabled;
            var _loc4_ = !this._bufferingBarHides || this.controls[index].myEnabled || this.controls[mx.video.UIManager.BUFFERING_BAR] == undefined || !this.controls[mx.video.UIManager.BUFFERING_BAR]._visible;
            this.controls[index]._visible = _loc4_;
            this.controls[index].progress_mc._visible = _loc4_;
            this.controls[index].progress_mc.fill_mc._visible = _loc4_;
            this.controls[index].fullness_mc._visible = _loc4_;
            this.controls[index].fullness_mc.fill_mc._visible = _loc4_;
            break;
         case mx.video.UIManager.BUFFERING_BAR:
            switch(_loc3_)
            {
               case mx.video.FLVPlayback.STOPPED:
               case mx.video.FLVPlayback.PLAYING:
               case mx.video.FLVPlayback.PAUSED:
               case mx.video.FLVPlayback.REWINDING:
               case mx.video.FLVPlayback.SEEKING:
                  this.controls[index].myEnabled = false;
                  break;
               default:
                  this.controls[index].myEnabled = true;
            }
            this.controls[index]._visible = this.controls[index].myEnabled;
            this.controls[index].fill_mc._visible = this.controls[index].myEnabled;
            break;
         case mx.video.UIManager.PAUSE_BUTTON:
            switch(_loc3_)
            {
               case mx.video.FLVPlayback.DISCONNECTED:
               case mx.video.FLVPlayback.STOPPED:
               case mx.video.FLVPlayback.PAUSED:
               case mx.video.FLVPlayback.REWINDING:
                  this.controls[index].myEnabled = false;
                  break;
               case mx.video.FLVPlayback.PLAYING:
                  this.controls[index].myEnabled = true;
                  break;
               case mx.video.FLVPlayback.BUFFERING:
                  this.controls[index].myEnabled = !this._bufferingBarHides || this.controls[mx.video.UIManager.BUFFERING_BAR] == undefined;
            }
            if(this.controls[mx.video.UIManager.PLAY_PAUSE_BUTTON] != undefined)
            {
               this.controls[index]._visible = this.controls[index].myEnabled;
            }
            break;
         case mx.video.UIManager.PLAY_BUTTON:
            switch(_loc3_)
            {
               case mx.video.FLVPlayback.PLAYING:
                  this.controls[index].myEnabled = false;
                  break;
               case mx.video.FLVPlayback.STOPPED:
               case mx.video.FLVPlayback.PAUSED:
                  this.controls[index].myEnabled = true;
                  break;
               case mx.video.FLVPlayback.BUFFERING:
                  this.controls[index].myEnabled = !this._bufferingBarHides || this.controls[mx.video.UIManager.BUFFERING_BAR] == undefined;
            }
            if(this.controls[mx.video.UIManager.PLAY_PAUSE_BUTTON] != undefined)
            {
               this.controls[index]._visible = !this.controls[mx.video.UIManager.PAUSE_BUTTON]._visible;
            }
            break;
         case mx.video.UIManager.STOP_BUTTON:
            switch(_loc3_)
            {
               case mx.video.FLVPlayback.DISCONNECTED:
               case mx.video.FLVPlayback.STOPPED:
                  this.controls[index].myEnabled = false;
                  break;
               case mx.video.FLVPlayback.PAUSED:
               case mx.video.FLVPlayback.PLAYING:
               case mx.video.FLVPlayback.BUFFERING:
                  this.controls[index].myEnabled = true;
            }
            break;
         case mx.video.UIManager.BACK_BUTTON:
         case mx.video.UIManager.FORWARD_BUTTON:
            if((_loc0_ = _loc3_) !== mx.video.FLVPlayback.BUFFERING)
            {
               break;
            }
            this.controls[index].myEnabled = !this._bufferingBarHides || this.controls[mx.video.UIManager.BUFFERING_BAR] == undefined;
            break;
      }
      this.controls[index].enabled = this._controlsEnabled && this.controls[index].myEnabled;
      this._vc.activeVideoPlayerIndex = _loc5_;
   }
   function setupSkinAutoHide()
   {
      if(this._skinAutoHide && this.skin_mc != undefined)
      {
         this.skinAutoHideHitTest();
         if(this._skinAutoHideIntervalID == 0)
         {
            this._skinAutoHideIntervalID = setInterval(this,"skinAutoHideHitTest",mx.video.UIManager.SKIN_AUTO_HIDE_INTERVAL);
         }
      }
      else
      {
         this.skin_mc._visible = this.__visible;
         clearInterval(this._skinAutoHideIntervalID);
         this._skinAutoHideIntervalID = 0;
      }
   }
   function skinAutoHideHitTest()
   {
      if(!this.__visible)
      {
         this.skin_mc._visible = false;
      }
      else
      {
         var _loc4_ = this._vc.getVideoPlayer(this._vc.visibleVideoPlayerIndex);
         var _loc3_ = _loc4_.hitTest(_root._xmouse,_root._ymouse,true);
         if(!_loc3_ && this.border_mc != undefined)
         {
            _loc3_ = this.border_mc.hitTest(_root._xmouse,_root._ymouse,true);
         }
         this.skin_mc._visible = _loc3_;
      }
   }
}
