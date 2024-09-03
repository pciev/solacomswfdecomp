class mx.video.SMILManager
{
   var _owner;
   var _url;
   var xml;
   var baseURLAttr;
   var videoTags;
   var width;
   var height;
   static var version = "1.0.2.8";
   static var shortVersion = "1.0.2";
   static var ELEMENT_NODE = 1;
   function SMILManager(owner)
   {
      this._owner = owner;
   }
   function connectXML(url)
   {
      this._url = this.fixURL(url);
      this.xml = new XML();
      this.xml.onLoad = mx.utils.Delegate.create(this,this.xmlOnLoad);
      this.xml.load(this._url);
      return false;
   }
   function fixURL(origURL)
   {
      if(origURL.substr(0,5).toLowerCase() == "http:" || origURL.substr(0,6).toLowerCase() == "https:")
      {
         var _loc2_ = origURL.indexOf("?") < 0 ? "?" : "&";
         return origURL + _loc2_ + "FLVPlaybackVersion=" + mx.video.SMILManager.shortVersion;
      }
      return origURL;
   }
   function xmlOnLoad(success)
   {
      try
      {
         if(!success)
         {
            this._owner.helperDone(this,false);
         }
         else
         {
            this.baseURLAttr = new Array();
            this.videoTags = new Array();
            var _loc2_ = this.xml.firstChild;
            var _loc6_ = false;
            while(_loc2_ != null)
            {
               if(_loc2_.nodeType == mx.video.SMILManager.ELEMENT_NODE)
               {
                  _loc6_ = true;
                  if(_loc2_.nodeName.toLowerCase() == "smil")
                  {
                     break;
                  }
               }
               _loc2_ = _loc2_.nextSibling;
            }
            if(!_loc6_)
            {
               throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" No root node found; if url is for an flv it must have .flv extension and take no parameters");
            }
            if(_loc2_ == null)
            {
               throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" Root node not smil");
            }
            var _loc5_ = false;
            var _loc4_ = 0;
            while(_loc4_ < _loc2_.childNodes.length)
            {
               var _loc3_ = _loc2_.childNodes[_loc4_];
               if(_loc3_.nodeType == mx.video.SMILManager.ELEMENT_NODE)
               {
                  if(_loc3_.nodeName.toLowerCase() == "head")
                  {
                     this.parseHead(_loc3_);
                  }
                  else
                  {
                     if(_loc3_.nodeName.toLowerCase() != "body")
                     {
                        throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" Tag " + _loc3_.nodeName + " not supported in " + _loc2_.nodeName + " tag.");
                     }
                     _loc5_ = true;
                     this.parseBody(_loc3_);
                  }
               }
               _loc4_ = _loc4_ + 1;
            }
            if(!_loc5_)
            {
               throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" Tag body is required.");
            }
            this._owner.helperDone(this,true);
         }
      }
      catch(err:Error)
      {
         this._owner.helperDone(this,false);
         throw err;
      }
   }
   function parseHead(parentNode)
   {
      var _loc4_ = false;
      var _loc3_ = 0;
      while(_loc3_ < parentNode.childNodes.length)
      {
         var _loc2_ = parentNode.childNodes[_loc3_];
         if(_loc2_.nodeType == mx.video.SMILManager.ELEMENT_NODE)
         {
            if(_loc2_.nodeName.toLowerCase() == "meta")
            {
               for(var _loc6_ in _loc2_.attributes)
               {
                  if(_loc6_.toLowerCase() != "base")
                  {
                     throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" Attribute " + _loc6_ + " not supported in " + _loc2_.nodeName + " tag.");
                  }
                  this.baseURLAttr.push(_loc2_.attributes[_loc6_]);
               }
            }
            else if(_loc2_.nodeName.toLowerCase() == "layout")
            {
               if(!_loc4_)
               {
                  this.parseLayout(_loc2_);
                  _loc4_ = true;
               }
            }
         }
         _loc3_ = _loc3_ + 1;
      }
   }
   function parseLayout(parentNode)
   {
      var _loc3_ = 0;
      while(_loc3_ < parentNode.childNodes.length)
      {
         var _loc2_ = parentNode.childNodes[_loc3_];
         if(_loc2_.nodeType == mx.video.SMILManager.ELEMENT_NODE)
         {
            if(_loc2_.nodeName.toLowerCase() == "root-layout")
            {
               for(var _loc5_ in _loc2_.attributes)
               {
                  if(_loc5_.toLowerCase() == "width")
                  {
                     this.width = Number(_loc2_.attributes[_loc5_]);
                  }
                  else if(_loc5_.toLowerCase() == "height")
                  {
                     this.height = Number(_loc2_.attributes[_loc5_]);
                  }
               }
               if(isNaN(this.width) || this.width < 0 || isNaN(this.height) || this.height < 0)
               {
                  throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" Tag " + _loc2_.nodeName + " requires attributes id, width and height.  Width and height must be numbers greater than or equal to 0.");
               }
               this.width = Math.round(this.width);
               this.height = Math.round(this.height);
               return undefined;
            }
         }
         _loc3_ = _loc3_ + 1;
      }
   }
   function parseBody(parentNode)
   {
      var _loc6_ = 0;
      var _loc3_ = 0;
      while(_loc3_ < parentNode.childNodes.length)
      {
         var _loc2_ = parentNode.childNodes[_loc3_];
         if(_loc2_.nodeType == mx.video.SMILManager.ELEMENT_NODE)
         {
            if((_loc6_ = _loc6_ + 1) > 1)
            {
               throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" Tag " + parentNode.nodeName + " is required to contain exactly one tag.");
            }
            if(_loc2_.nodeName.toLowerCase() == "switch")
            {
               this.parseSwitch(_loc2_);
            }
            else if(_loc2_.nodeName.toLowerCase() == "video" || _loc2_.nodeName.toLowerCase() == "ref")
            {
               var _loc5_ = this.parseVideo(_loc2_);
               this.videoTags.push(_loc5_);
            }
         }
         _loc3_ = _loc3_ + 1;
      }
      if(this.videoTags.length < 1)
      {
         throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" At least one video of ref tag is required.");
      }
   }
   function parseSwitch(parentNode)
   {
      var _loc3_ = 0;
      while(_loc3_ < parentNode.childNodes.length)
      {
         var _loc2_ = parentNode.childNodes[_loc3_];
         if(_loc2_.nodeType == mx.video.SMILManager.ELEMENT_NODE)
         {
            if(_loc2_.nodeName.toLowerCase() == "video" || _loc2_.nodeName.toLowerCase() == "ref")
            {
               this.videoTags.push(this.parseVideo(_loc2_));
            }
         }
         _loc3_ = _loc3_ + 1;
      }
   }
   function parseVideo(node)
   {
      var _loc3_ = new Object();
      for(var _loc4_ in node.attributes)
      {
         if(_loc4_.toLowerCase() == "src")
         {
            _loc3_.src = node.attributes[_loc4_];
         }
         else if(_loc4_.toLowerCase() == "system-bitrate")
         {
            _loc3_.bitrate = Number(node.attributes[_loc4_]);
         }
         else if(_loc4_.toLowerCase() == "dur")
         {
            _loc3_.dur = this.parseTime(node.attributes[_loc4_]);
         }
      }
      if(_loc3_.src == undefined)
      {
         throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" Attribute src is required in " + node.nodeName + " tag.");
      }
      return _loc3_;
   }
   function parseTime(timeStr)
   {
      var _loc4_ = 0;
      var _loc3_ = timeStr.split(":");
      if(_loc3_.length < 1 || _loc3_.length > 3)
      {
         throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"Invalid dur value: " + timeStr);
      }
      var _loc1_ = 0;
      while(_loc1_ < _loc3_.length)
      {
         var _loc2_ = Number(_loc3_[_loc1_]);
         if(isNaN(_loc2_))
         {
            throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"Invalid dur value: " + timeStr);
         }
         _loc4_ *= 60;
         _loc4_ += _loc2_;
         _loc1_ = _loc1_ + 1;
      }
      return _loc4_;
   }
}
