Interfaces.Restoreable=new Class({
    
    _$Restoreable:function(){
        
    },
    restore:function(){
    var tmp=window.localStorage.getItem(this.options.cookieID+'.state');
    if(tmp=="visible")
      this.show();
  },
  savePosition:function(){
	if(this.base.isVisible() && $chk(this.options.cookieID)){
	  var position=this.base.getPosition();
	  /* Cookie for online */
	  if(this.options.useCookie){
	  Cookie.write(this.options.cookieID+'.x',position.x,{duration:Globals.cookieDuration});
	  Cookie.write(this.options.cookieID+'.y',position.y,{duration:Globals.cookieDuration});
          }else{
	  /* LocalStorage for offline*/
	  window.localStorage.setItem(this.options.cookieID+'.x',position.x);
	  window.localStorage.setItem(this.options.cookieID+'.y',position.y);
          }
	}
  },
  /**
   *  
   *  Loads the position of the panel from a cookie specified by the cookieID option.
   *  
   *
   **/
  loadPosition:function(){
	if($chk(this.options.cookieID)){
	  if($chk(window.localStorage.getItem(this.options.cookieID+'.y'))){
            if(this.options.useCookie){
                //cookie
            }else{
                this.base.setStyle('top',window.localStorage.getItem(this.options.cookieID+'.y')+"px");
                this.base.setStyle('left',window.localStorage.getItem(this.options.cookieID+'.x')+"px");
            }
	  }else{
	    this.base.position('center');
	  }
	}else{
	  this.base.position('center');
	}
  },
})