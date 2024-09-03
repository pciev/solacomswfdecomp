bytes_loaded = Math.round(this.getBytesLoaded());
bytes_total = Math.round(this.getBytesTotal());
getPercent = bytes_loaded / bytes_total;
this.loadBar._width = getPercent * 100;
this.loadPercent = Math.round(getPercent * 100) + "%";
if(bytes_loaded == bytes_total)
{
   this.gotoAndPlay(3);
}
