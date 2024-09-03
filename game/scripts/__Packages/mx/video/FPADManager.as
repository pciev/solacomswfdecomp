class mx.video.FPADManager
{
   var _owner;
   var _uriParam;
   var _parseResults;
   var _url;
   var xml;
   var rtmpURL;
   static var version = "1.0.2.8";
   static var shortVersion = "1.0.2";
   static var ELEMENT_NODE = 1;
   static var TEXT_NODE = 3;
   function FPADManager(owner)
   {
      this._owner = owner;
   }
   function connectXML(urlPrefix, uriParam, urlSuffix, uriParamParseResults)
   {
      this._uriParam = uriParam;
      this._parseResults = uriParamParseResults;
      this._url = urlPrefix + "uri=" + this._parseResults.protocol;
      if(this._parseResults.serverName != undefined)
      {
         this._url += "/" + this._parseResults.serverName;
      }
      if(this._parseResults.portNumber != undefined)
      {
         this._url += ":" + this._parseResults.portNumber;
      }
      if(this._parseResults.wrappedURL != undefined)
      {
         this._url += "/?" + this._parseResults.wrappedURL;
      }
      this._url += "/" + this._parseResults.appName;
      this._url += urlSuffix;
      this.xml = new XML();
      this.xml.onLoad = mx.utils.Delegate.create(this,this.xmlOnLoad);
      this.xml.load(this._url);
      return false;
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
            var _loc5_ = this.xml.firstChild;
            var _loc8_ = false;
            while(_loc5_ != null)
            {
               if(_loc5_.nodeType == mx.video.FPADManager.ELEMENT_NODE)
               {
                  _loc8_ = true;
                  if(_loc5_.nodeName.toLowerCase() == "fpad")
                  {
                     break;
                  }
               }
               _loc5_ = _loc5_.nextSibling;
            }
            if(!_loc8_)
            {
               throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" No root node found; if url is for an flv it must have .flv extension and take no parameters");
            }
            if(_loc5_ == null)
            {
               throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" Root node not fpad");
            }
            var _loc7_ = undefined;
            var _loc6_ = 0;
            while(_loc6_ < _loc5_.childNodes.length)
            {
               var _loc3_ = _loc5_.childNodes[_loc6_];
               if(_loc3_.nodeType == mx.video.FPADManager.ELEMENT_NODE)
               {
                  if(_loc3_.nodeName.toLowerCase() == "proxy")
                  {
                     var _loc2_ = 0;
                     while(_loc2_ < _loc3_.childNodes.length)
                     {
                        var _loc4_ = _loc3_.childNodes[_loc2_];
                        if(_loc4_.nodeType == mx.video.FPADManager.TEXT_NODE)
                        {
                           _loc7_ = this.trim(_loc4_.nodeValue);
                           break;
                        }
                        _loc2_ = _loc2_ + 1;
                     }
                     break;
                  }
               }
               _loc6_ = _loc6_ + 1;
            }
            if(_loc7_ == undefined || _loc7_ == "")
            {
               throw new mx.video.VideoError(mx.video.VideoError.INVALID_XML,"URL: \"" + this._url + "\" fpad xml requires proxy tag.");
            }
            this.rtmpURL = this._parseResults.protocol + "/" + _loc7_ + "/?" + this._uriParam;
            this._owner.helperDone(this,true);
         }
      }
      catch(err:Error)
      {
         this._owner.helperDone(this,false);
         throw err;
      }
   }
   function trim(str)
   {
      var _loc2_ = 0;
      while(_loc2_ < str.length)
      {
         var _loc1_ = str.charAt(_loc2_);
         if(_loc1_ != " " && _loc1_ != "\t" && _loc1_ != "\r" && _loc1_ != "\n")
         {
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(_loc2_ >= str.length)
      {
         return "";
      }
      var _loc4_ = str.length - 1;
      while(_loc4_ > _loc2_)
      {
         _loc1_ = str.charAt(_loc4_);
         if(_loc1_ != " " && _loc1_ != "\t" && _loc1_ != "\r" && _loc1_ != "\n")
         {
            break;
         }
         _loc4_ = _loc4_ - 1;
      }
      return str.slice(_loc2_,_loc4_ + 1);
   }
}
