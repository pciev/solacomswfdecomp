class mx.video.NCManager implements mx.video.INCManager
{
   var _timeoutIntervalId;
   var _tryNCIntervalId;
   var _timeout;
   var _nc;
   var _ncConnected;
   var _isRTMP;
   var _serverName;
   var _wrappedURL;
   var _portNumber;
   var _appName;
   var _contentPath;
   var _streamName;
   var _streamLength;
   var _streamWidth;
   var _streamHeight;
   var _streams;
   var _autoSenseBW;
   var fpadZone;
   var _payload;
   var _connTypeCounter;
   var _bitrate;
   var _owner;
   var _protocol;
   var _smilMgr;
   var mc;
   var _ncUri;
   var _fpadMgr;
   var fallbackServerName;
   var _tryNC;
   static var version = "1.0.2.8";
   static var shortVersion = "1.0.2";
   var DEFAULT_TIMEOUT = 60000;
   function NCManager()
   {
      this.initNCInfo();
      this.initOtherInfo();
      this._timeoutIntervalId = 0;
      this._tryNCIntervalId = 0;
      this._timeout = this.DEFAULT_TIMEOUT;
      this._nc = undefined;
      this._ncConnected = false;
   }
   function initNCInfo()
   {
      this._isRTMP = undefined;
      this._serverName = undefined;
      this._wrappedURL = undefined;
      this._portNumber = undefined;
      this._appName = undefined;
   }
   function initOtherInfo()
   {
      this._contentPath = undefined;
      this._streamName = undefined;
      this._streamLength = undefined;
      this._streamWidth = undefined;
      this._streamHeight = undefined;
      this._streams = undefined;
      this._autoSenseBW = false;
      this.fpadZone = undefined;
      this._payload = 0;
      this._connTypeCounter = 0;
      this.cleanConns();
   }
   function getTimeout()
   {
      return this._timeout;
   }
   function setTimeout(t)
   {
      this._timeout = t;
      if(this._timeoutIntervalId != 0)
      {
         clearInterval(this._timeoutIntervalId);
         this._timeoutIntervalId = setInterval(this,"_onFCSConnectTimeOut",this._timeout);
      }
   }
   function getBitrate()
   {
      return this._bitrate;
   }
   function setBitrate(b)
   {
      if(this._isRTMP == undefined || !this._isRTMP)
      {
         this._bitrate = b;
      }
   }
   function getVideoPlayer()
   {
      return this._owner;
   }
   function setVideoPlayer(v)
   {
      this._owner = v;
   }
   function getNetConnection()
   {
      return this._nc;
   }
   function getStreamName()
   {
      return this._streamName;
   }
   function isRTMP()
   {
      return this._isRTMP;
   }
   function getStreamLength()
   {
      return this._streamLength;
   }
   function getStreamWidth()
   {
      return this._streamWidth;
   }
   function getStreamHeight()
   {
      return this._streamHeight;
   }
   function connectToURL(url)
   {
      this.initOtherInfo();
      this._contentPath = url;
      if(this._contentPath == null || this._contentPath == "")
      {
         throw new mx.video.VideoError(mx.video.VideoError.INVALID_CONTENT_PATH);
      }
      var _loc2_ = this.parseURL(this._contentPath);
      if(_loc2_.streamName == undefined || _loc2_.streamName == "")
      {
         throw new mx.video.VideoError(mx.video.VideoError.INVALID_CONTENT_PATH,url);
      }
      if(_loc2_.isRTMP)
      {
         var _loc4_ = this.canReuseOldConnection(_loc2_);
         this._isRTMP = true;
         this._protocol = _loc2_.protocol;
         this._streamName = _loc2_.streamName;
         this._serverName = _loc2_.serverName;
         this._wrappedURL = _loc2_.wrappedURL;
         this._portNumber = _loc2_.portNumber;
         this._appName = _loc2_.appName;
         if(this._appName == undefined || this._appName == "" || this._streamName == undefined || this._streamName == "")
         {
            throw new mx.video.VideoError(mx.video.VideoError.INVALID_CONTENT_PATH,url);
         }
         this._autoSenseBW = this._streamName.indexOf(",") >= 0;
         return _loc4_ || this.connectRTMP();
      }
      var _loc3_ = _loc2_.streamName;
      if(_loc3_.indexOf("?") < 0 && (_loc3_.length < 4 || _loc3_.slice(-4).toLowerCase() != ".txt") && (_loc3_.length < 4 || _loc3_.slice(-4).toLowerCase() != ".xml") && (_loc3_.length < 5 || _loc3_.slice(-5).toLowerCase() != ".smil"))
      {
         _loc4_ = this.canReuseOldConnection(_loc2_);
         this._isRTMP = false;
         this._streamName = _loc3_;
         return _loc4_ || this.connectHTTP();
      }
      if(_loc3_.indexOf("/fms/fpad") >= 0)
      {
         try
         {
            return this.connectFPAD(_loc3_);
         }
         catch(err:Error)
         {
         }
      }
      this._smilMgr = new mx.video.SMILManager(this);
      return this._smilMgr.connectXML(_loc3_);
   }
   function connectAgain()
   {
      var _loc2_ = this._appName.indexOf("/");
      if(_loc2_ < 0)
      {
         _loc2_ = this._streamName.indexOf("/");
         if(_loc2_ >= 0)
         {
            this._appName += "/";
            this._appName += this._streamName.slice(0,_loc2_);
            this._streamName = this._streamName.slice(_loc2_ + 1);
         }
         return false;
      }
      var _loc3_ = this._appName.slice(_loc2_ + 1);
      _loc3_ += "/";
      _loc3_ += this._streamName;
      this._streamName = _loc3_;
      this._appName = this._appName.slice(0,_loc2_);
      this.close();
      this._payload = 0;
      this._connTypeCounter = 0;
      this.cleanConns();
      this.connectRTMP();
      return true;
   }
   function reconnect()
   {
      if(!this._isRTMP)
      {
         throw new Error("Cannot call reconnect on an http connection");
      }
      this._nc.onStatus = function(info)
      {
         this.mc.reconnectOnStatus(this,info);
      };
      this._nc.onBWDone = function()
      {
         this.mc.onReconnected();
      };
      this._nc.connect(this._ncUri,false);
   }
   function onReconnected()
   {
      delete this._nc.onStatus;
      delete this._nc.onBWDone;
      this._ncConnected = true;
      this._owner.ncReconnected();
   }
   function close()
   {
      if(this._nc)
      {
         this._nc.close();
         this._ncConnected = false;
      }
   }
   function helperDone(helper, success)
   {
      if(!success)
      {
         this._nc = undefined;
         this._ncConnected = false;
         this._owner.ncConnected();
         this._smilMgr = undefined;
         this._fpadMgr = undefined;
         return undefined;
      }
      var _loc2_ = undefined;
      var _loc4_ = undefined;
      if(helper == this._fpadMgr)
      {
         _loc4_ = this._fpadMgr.rtmpURL;
         this._fpadMgr = undefined;
         _loc2_ = this.parseURL(_loc4_);
         this._isRTMP = _loc2_.isRTMP;
         this._protocol = _loc2_.protocol;
         this._serverName = _loc2_.serverName;
         this._portNumber = _loc2_.portNumber;
         this._wrappedURL = _loc2_.wrappedURL;
         this._appName = _loc2_.appName;
         this._streamName = _loc2_.streamName;
         var _loc5_ = this.fpadZone;
         this.fpadZone = -1;
         this.connectRTMP();
         this.fpadZone = _loc5_;
         return undefined;
      }
      if(helper != this._smilMgr)
      {
         return undefined;
      }
      this._streamWidth = this._smilMgr.width;
      this._streamHeight = this._smilMgr.height;
      _loc4_ = this._smilMgr.baseURLAttr[0];
      if(_loc4_ != undefined && _loc4_ != "")
      {
         if(_loc4_.charAt(_loc4_.length - 1) != "/")
         {
            _loc4_ += "/";
         }
         _loc2_ = this.parseURL(_loc4_);
         this._isRTMP = _loc2_.isRTMP;
         this._streamName = _loc2_.streamName;
         if(this._isRTMP)
         {
            this._protocol = _loc2_.protocol;
            this._serverName = _loc2_.serverName;
            this._portNumber = _loc2_.portNumber;
            this._wrappedURL = _loc2_.wrappedURL;
            this._appName = _loc2_.appName;
            if(this._appName == undefined || this._appName == "")
            {
               this._smilMgr = undefined;
               throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"Base RTMP URL must include application name: " + _loc4_);
            }
            if(this._smilMgr.baseURLAttr.length > 1)
            {
               _loc2_ = this.parseURL(this._smilMgr.baseURLAttr[1]);
               if(_loc2_.serverName != undefined)
               {
                  this.fallbackServerName = _loc2_.serverName;
               }
            }
         }
      }
      this._streams = this._smilMgr.videoTags;
      this._smilMgr = undefined;
      var _loc3_ = 0;
      while(_loc3_ < this._streams.length)
      {
         _loc4_ = this._streams[_loc3_].src;
         _loc2_ = this.parseURL(_loc4_);
         if(this._isRTMP == undefined)
         {
            this._isRTMP = _loc2_.isRTMP;
            if(this._isRTMP)
            {
               this._protocol = _loc2_.protocol;
               if(this._streams.length > 1)
               {
                  throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"Cannot switch between multiple absolute RTMP URLs, must use meta tag base attribute.");
               }
               this._serverName = _loc2_.serverName;
               this._portNumber = _loc2_.portNumber;
               this._wrappedURL = _loc2_.wrappedURL;
               this._appName = _loc2_.appName;
               if(this._appName == undefined || this._appName == "")
               {
                  throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"Base RTMP URL must include application name: " + _loc4_);
               }
            }
            else if(_loc2_.streamName.indexOf("/fms/fpad") >= 0 && this._streams.length > 1)
            {
               throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"Cannot switch between multiple absolute fpad URLs, must use meta tag base attribute.");
            }
         }
         else if(this._streamName != undefined && this._streamName != "" && !_loc2_.isRelative && this._streams.length > 1)
         {
            throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"When using meta tag base attribute, cannot use absolute URLs for video or ref tag src attributes.");
         }
         this._streams[_loc3_].parseResults = _loc2_;
         _loc3_ = _loc3_ + 1;
      }
      this._autoSenseBW = this._streams.length > 1;
      if(!this._autoSenseBW)
      {
         if(this._streamName != undefined)
         {
            this._streamName += this._streams[0].parseResults.streamName;
         }
         else
         {
            this._streamName = this._streams[0].parseResults.streamName;
         }
         this._streamLength = this._streams[0].dur;
      }
      if(this._isRTMP)
      {
         this.connectRTMP();
      }
      else if(this._streamName != undefined && this._streamName.indexOf("/fms/fpad") >= 0)
      {
         this.connectFPAD(this._streamName);
      }
      else
      {
         if(this._autoSenseBW)
         {
            this.bitrateMatch();
         }
         this.connectHTTP();
         this._owner.ncConnected();
      }
   }
   function bitrateMatch()
   {
      var _loc3_ = undefined;
      var _loc4_ = this._bitrate;
      if(isNaN(_loc4_))
      {
         _loc4_ = 0;
      }
      var _loc2_ = 0;
      while(_loc2_ < this._streams.length)
      {
         if(isNaN(this._streams[_loc2_].bitrate) || _loc4_ >= this._streams[_loc2_].bitrate)
         {
            _loc3_ = _loc2_;
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(isNaN(_loc3_))
      {
         throw new mx.video.VideoError(mx.video.VideoError.NO_BITRATE_MATCH);
      }
      if(this._streamName != undefined)
      {
         this._streamName += this._streams[_loc3_].src;
      }
      else
      {
         this._streamName = this._streams[_loc3_].src;
      }
      if(this._isRTMP && this._streamName.slice(-4).toLowerCase() == ".flv")
      {
         this._streamName = this._streamName.slice(0,-4);
      }
      this._streamLength = this._streams[_loc3_].dur;
   }
   function parseURL(url)
   {
      var _loc2_ = new Object();
      var _loc3_ = 0;
      var _loc4_ = url.indexOf(":/",_loc3_);
      if(_loc4_ >= 0)
      {
         _loc4_ += 2;
         _loc2_.protocol = url.slice(_loc3_,_loc4_);
         _loc2_.isRelative = false;
      }
      else
      {
         _loc2_.isRelative = true;
      }
      if(_loc2_.protocol != undefined && (_loc2_.protocol == "rtmp:/" || _loc2_.protocol == "rtmpt:/" || _loc2_.protocol == "rtmps:/" || _loc2_.protocol == "rtmpe:/" || _loc2_.protocol == "rtmpte:/"))
      {
         _loc2_.isRTMP = true;
         _loc3_ = _loc4_;
         if(url.charAt(_loc3_) == "/")
         {
            _loc3_ = _loc3_ + 1;
            var _loc7_ = url.indexOf(":",_loc3_);
            var _loc8_ = url.indexOf("/",_loc3_);
            if(_loc8_ < 0)
            {
               if(_loc7_ < 0)
               {
                  _loc2_.serverName = url.slice(_loc3_);
               }
               else
               {
                  _loc4_ = _loc7_;
                  _loc2_.portNumber = url.slice(_loc3_,_loc4_);
                  _loc3_ = _loc4_ + 1;
                  _loc2_.serverName = url.slice(_loc3_);
               }
               return _loc2_;
            }
            if(_loc7_ >= 0 && _loc7_ < _loc8_)
            {
               _loc4_ = _loc7_;
               _loc2_.serverName = url.slice(_loc3_,_loc4_);
               _loc3_ = _loc4_ + 1;
               _loc4_ = _loc8_;
               _loc2_.portNumber = url.slice(_loc3_,_loc4_);
            }
            else
            {
               _loc4_ = _loc8_;
               _loc2_.serverName = url.slice(_loc3_,_loc4_);
            }
            _loc3_ = _loc4_ + 1;
         }
         if(url.charAt(_loc3_) == "?")
         {
            var _loc9_ = url.slice(_loc3_ + 1);
            var _loc6_ = this.parseURL(_loc9_);
            if(_loc6_.protocol == undefined || !_loc6_.isRTMP)
            {
               throw new mx.video.VideoError(mx.video.VideoError.INVALID_CONTENT_PATH,url);
            }
            _loc2_.wrappedURL = "?";
            _loc2_.wrappedURL += _loc6_.protocol;
            if(_loc6_.serverName != undefined)
            {
               _loc2_.wrappedURL += "/";
               _loc2_.wrappedURL += _loc6_.serverName;
            }
            if(_loc6_.wrappedURL != undefined)
            {
               _loc2_.wrappedURL += "/?";
               _loc2_.wrappedURL += _loc6_.wrappedURL;
            }
            _loc2_.appName = _loc6_.appName;
            _loc2_.streamName = _loc6_.streamName;
            return _loc2_;
         }
         _loc4_ = url.indexOf("/",_loc3_);
         if(_loc4_ < 0)
         {
            _loc2_.appName = url.slice(_loc3_);
            return _loc2_;
         }
         _loc2_.appName = url.slice(_loc3_,_loc4_);
         _loc3_ = _loc4_ + 1;
         _loc4_ = url.indexOf("/",_loc3_);
         if(_loc4_ < 0)
         {
            _loc2_.streamName = url.slice(_loc3_);
            if(_loc2_.streamName.slice(-4).toLowerCase() == ".flv")
            {
               _loc2_.streamName = _loc2_.streamName.slice(0,-4);
            }
            return _loc2_;
         }
         _loc2_.appName += "/";
         _loc2_.appName += url.slice(_loc3_,_loc4_);
         _loc3_ = _loc4_ + 1;
         _loc2_.streamName = url.slice(_loc3_);
         if(_loc2_.streamName.slice(-4).toLowerCase() == ".flv")
         {
            _loc2_.streamName = _loc2_.streamName.slice(0,-4);
         }
      }
      else
      {
         _loc2_.isRTMP = false;
         _loc2_.streamName = url;
      }
      return _loc2_;
   }
   function canReuseOldConnection(parseResults)
   {
      if(this._nc == null || !this._ncConnected)
      {
         return false;
      }
      if(!parseResults.isRTMP)
      {
         if(!this._isRTMP)
         {
            return true;
         }
         this._owner.close();
         this._nc = undefined;
         this._ncConnected = false;
         this.initNCInfo();
         return false;
      }
      if(this._isRTMP)
      {
         if(parseResults.serverName == this._serverName && parseResults.appName == this._appName && parseResults.protocol == this._protocol && parseResults.portNumber == this._portNumber && parseResults.wrappedURL == this._wrappedURL)
         {
            return true;
         }
         this._owner.close();
         this._nc = undefined;
         this._ncConnected = false;
      }
      this.initNCInfo();
      return false;
   }
   function connectHTTP()
   {
      this._nc = new NetConnection();
      this._nc.connect(null);
      this._ncConnected = true;
      return true;
   }
   function connectRTMP()
   {
      clearInterval(this._timeoutIntervalId);
      this._timeoutIntervalId = setInterval(this,"_onFCSConnectTimeOut",this._timeout);
      this._tryNC = new Array();
      var _loc3_ = !(this._protocol == "rtmp:/" || this._protocol == "rtmpe:/") ? 1 : 2;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_)
      {
         this._tryNC[_loc2_] = new NetConnection();
         if(this.fpadZone != null)
         {
            this._tryNC[_loc2_].fpadZone = this.fpadZone;
         }
         this._tryNC[_loc2_].mc = this;
         this._tryNC[_loc2_].pending = false;
         this._tryNC[_loc2_].connIndex = _loc2_;
         this._tryNC[_loc2_].onBWDone = function(p_bw)
         {
            this.mc.onConnected(this,p_bw);
         };
         this._tryNC[_loc2_].onBWCheck = function()
         {
            return ++this.mc._payload;
         };
         this._tryNC[_loc2_].onStatus = function(info)
         {
            this.mc.connectOnStatus(this,info);
         };
         _loc2_ = _loc2_ + 1;
      }
      this.nextConnect();
      return false;
   }
   function connectFPAD(url)
   {
      var _loc7_ = undefined;
      var _loc5_ = undefined;
      var _loc6_ = undefined;
      var _loc2_ = url.indexOf("?");
      while(_loc2_ >= 0)
      {
         _loc2_ = _loc2_ + 1;
         var _loc4_ = url.indexOf("&",_loc2_);
         if(url.substr(_loc2_,4).toLowerCase() == "uri=")
         {
            _loc7_ = url.slice(0,_loc2_);
            _loc2_ += 4;
            if(_loc4_ >= 0)
            {
               _loc5_ = url.slice(_loc2_,_loc4_);
               _loc6_ = url.slice(_loc4_);
            }
            else
            {
               _loc5_ = url.slice(_loc2_);
               _loc6_ = "";
            }
            break;
         }
         _loc2_ = _loc4_;
      }
      if(_loc2_ < 0)
      {
         throw new mx.video.VideoError(mx.video.VideoError.INVALID_CONTENT_PATH,"fpad url must include uri parameter: " + url);
      }
      var _loc8_ = this.parseURL(_loc5_);
      if(!_loc8_.isRTMP)
      {
         throw new mx.video.VideoError(mx.video.VideoError.INVALID_CONTENT_PATH,"fpad url uri parameter must be rtmp url: " + url);
      }
      this._fpadMgr = new mx.video.FPADManager(this);
      return this._fpadMgr.connectXML(_loc7_,_loc5_,_loc6_,_loc8_);
   }
   function nextConnect()
   {
      clearInterval(this._tryNCIntervalId);
      this._tryNCIntervalId = 0;
      var _loc3_ = undefined;
      var _loc2_ = undefined;
      if(this._connTypeCounter == 0)
      {
         _loc3_ = this._protocol;
         _loc2_ = this._portNumber;
      }
      else
      {
         _loc2_ = null;
         if(this._protocol == "rtmp:/")
         {
            _loc3_ = "rtmpt:/";
         }
         else
         {
            if(this._protocol != "rtmpe:/")
            {
               this._tryNC.pop();
               return undefined;
            }
            _loc3_ = "rtmpte:/";
         }
      }
      var _loc4_ = _loc3_ + (this._serverName != undefined ? "/" + this._serverName + (_loc2_ != null ? ":" + _loc2_ : "") + "/" : "") + (this._wrappedURL != undefined ? this._wrappedURL + "/" : "") + this._appName;
      this._tryNC[this._connTypeCounter].pending = true;
      this._tryNC[this._connTypeCounter].connect(_loc4_,this._autoSenseBW);
      if(this._connTypeCounter < this._tryNC.length - 1)
      {
         this._connTypeCounter = this._connTypeCounter + 1;
         this._tryNCIntervalId = setInterval(this,"nextConnect",1500);
      }
   }
   function cleanConns()
   {
      clearInterval(this._tryNCIntervalId);
      this._tryNCIntervalId = 0;
      if(this._tryNC != undefined)
      {
         var _loc2_ = 0;
         while(_loc2_ < this._tryNC.length)
         {
            if(this._tryNC[_loc2_] != undefined)
            {
               delete this._tryNC[_loc2_].onStatus;
               if(this._tryNC[_loc2_].pending)
               {
                  this._tryNC[_loc2_].onStatus = function(info)
                  {
                     this.mc.disconnectOnStatus(this,info);
                  };
               }
               else
               {
                  delete this._tryNC[_loc2_].onStatus;
                  this._tryNC[_loc2_].close();
               }
            }
            delete this._tryNC[_loc2_];
            _loc2_ = _loc2_ + 1;
         }
         delete this._tryNC;
      }
   }
   function tryFallBack()
   {
      if(this._serverName == this.fallbackServerName || this.fallbackServerName == undefined || this.fallbackServerName == null)
      {
         delete this._nc;
         this._nc = undefined;
         this._ncConnected = false;
         this._owner.ncConnected();
      }
      else
      {
         this._connTypeCounter = 0;
         this.cleanConns();
         this._serverName = this.fallbackServerName;
         this.connectRTMP();
      }
   }
   function onConnected(p_nc, p_bw)
   {
      clearInterval(this._timeoutIntervalId);
      this._timeoutIntervalId = 0;
      delete p_nc.onBWDone;
      delete p_nc.onBWCheck;
      delete p_nc.onStatus;
      this._nc = p_nc;
      this._ncUri = this._nc.uri;
      this._ncConnected = true;
      if(this._autoSenseBW)
      {
         this._bitrate = p_bw * 1024;
         if(this._streams != undefined)
         {
            this.bitrateMatch();
         }
         else
         {
            var _loc3_ = this._streamName.split(",");
            var _loc2_ = 0;
            while(_loc2_ < _loc3_.length)
            {
               var _loc4_ = mx.video.NCManager.stripFrontAndBackWhiteSpace(_loc3_[_loc2_]);
               if(_loc2_ + 1 >= _loc3_.length)
               {
                  this._streamName = _loc4_;
                  break;
               }
               if(p_bw <= Number(_loc3_[_loc2_ + 1]))
               {
                  this._streamName = _loc4_;
                  break;
               }
               _loc2_ += 2;
            }
            if(this._streamName.slice(-4).toLowerCase() == ".flv")
            {
               this._streamName = this._streamName.slice(0,-4);
            }
         }
      }
      if(!this._owner.isLive && this._streamLength == undefined)
      {
         var _loc6_ = new Object();
         _loc6_.mc = this;
         _loc6_.onResult = function(length)
         {
            this.mc.getStreamLengthResult(length);
         };
         this._nc.call("getStreamLength",_loc6_,this._streamName);
      }
      else
      {
         this._owner.ncConnected();
      }
   }
   function connectOnStatus(target, info)
   {
      target.pending = false;
      if(info.code == "NetConnection.Connect.Success")
      {
         this._nc = this._tryNC[target.connIndex];
         this._tryNC[target.connIndex] = undefined;
         this.cleanConns();
      }
      else if(info.code == "NetConnection.Connect.Rejected" && info.ex != null && info.ex.code == 302)
      {
         this._connTypeCounter = 0;
         this.cleanConns();
         var _loc2_ = this.parseURL(info.ex.redirect);
         if(_loc2_.isRTMP)
         {
            this._protocol = _loc2_.protocol;
            this._serverName = _loc2_.serverName;
            this._wrappedURL = _loc2_.wrappedURL;
            this._portNumber = _loc2_.portNumber;
            this._appName = _loc2_.appName;
            if(_loc2_.streamName != null)
            {
               this._appName += "/" + _loc2_.streamName;
            }
            this.connectRTMP();
         }
         else
         {
            this.tryFallBack();
         }
      }
      else if((info.code == "NetConnection.Connect.Failed" || info.code == "NetConnection.Connect.Rejected") && target.connIndex == this._tryNC.length - 1)
      {
         if(!this.connectAgain())
         {
            this.tryFallBack();
         }
      }
   }
   function reconnectOnStatus(target, info)
   {
      if(info.code == "NetConnection.Connect.Failed" || info.code == "NetConnection.Connect.Rejected")
      {
         delete this._nc;
         this._nc = undefined;
         this._ncConnected = false;
         this._owner.ncReconnected();
      }
   }
   function disconnectOnStatus(target, info)
   {
      if(info.code == "NetConnection.Connect.Success")
      {
         delete target.onStatus;
         target.close();
      }
   }
   function getStreamLengthResult(length)
   {
      if(length > 0)
      {
         this._streamLength = length;
      }
      this._owner.ncConnected();
   }
   function _onFCSConnectTimeOut()
   {
      this.cleanConns();
      this._nc = undefined;
      this._ncConnected = false;
      if(!this.connectAgain())
      {
         this._owner.ncConnected();
      }
   }
   static function stripFrontAndBackWhiteSpace(p_str)
   {
      var _loc1_ = undefined;
      var _loc2_ = p_str.length;
      var _loc4_ = 0;
      var _loc5_ = _loc2_;
      _loc1_ = 0;
      while(_loc1_ < _loc2_)
      {
         switch(p_str.charCodeAt(_loc1_))
         {
            case 9:
            case 10:
            case 13:
            case 32:
               break;
            default:
               _loc4_ = _loc1_;
         }
         _loc1_ = _loc1_ + 1;
      }
      _loc1_ = _loc2_;
      while(_loc1_ >= 0)
      {
         switch(p_str.charCodeAt(_loc1_))
         {
            case 9:
            case 10:
            case 13:
            case 32:
               break;
            default:
               _loc5_ = _loc1_ + 1;
         }
         _loc1_ = _loc1_ - 1;
      }
      if(_loc5_ <= _loc4_)
      {
         return "";
      }
      return p_str.slice(_loc4_,_loc5_);
   }
}
