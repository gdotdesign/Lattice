/*
---

name: Interfaces.Restoreable

description: 

license: MIT-style license.

requires: 

provides: Interfaces.Restoreable

...
*/
Interfaces.Restoreable=new Class({
    Impelments:[Options],
    options:{
        useCookie:true,
        cookieID:null
    },
    _$Restoreable:function(){
      GDotUI.addEvent('init',this.loadPosition.bindWithEvent(this));
      this.addEvent('hide',function(){
        if($chk(this.options.cookieID)){
          if(this.options.useCookie){
            Cookie.write(this.options.cookieID+'.state','hidden',{duration:GDotUI.Config.cookieDuration});
          }else{
            window.localStorage.setItem(this.options.cookieID+'.state','hidden');
          }
        }
      }.bindWithEvent(this));
      this.addEvent('dropped',this.savePosition.bindWithEvent(this));
    },
    savePosition:function(){
      if($chk(this.options.cookieID)){
        var position=this.base.getPosition();
        var state=this.base.isVisible()?'visible':'hidden';
          if(this.options.useCookie){
            Cookie.write(this.options.cookieID+'.x',position.x,{duration:GDotUI.Config.cookieDuration});
            Cookie.write(this.options.cookieID+'.y',position.y,{duration:GDotUI.Config.cookieDuration});
            Cookie.write(this.options.cookieID+'.state',state,{duration:GDotUI.Config.cookieDuration});
          }else{
            window.localStorage.setItem(this.options.cookieID+'.x',position.x);
            window.localStorage.setItem(this.options.cookieID+'.y',position.y);
            window.localStorage.setItem(this.options.cookieID+'.state',state);
          }
      }
    },
    loadPosition:function(){
      if($chk(this.options.cookieID)){
        if(this.options.useCookie){
          this.base.setStyle('top',Cookie.read(this.options.cookieID+'.y')+"px");
          this.base.setStyle('left',Cookie.read(this.options.cookieID+'.x')+"px");
          if(Cookie.read(this.options.cookieID+'.state')=="hidden")
            this.hide();
        }else{
          this.base.setStyle('top',window.localStorage.getItem(this.options.cookieID+'.y')+"px");
          this.base.setStyle('left',window.localStorage.getItem(this.options.cookieID+'.x')+"px");
          if(window.localStorage.getItem(this.options.cookieID+'.state')=="hidden")
            this.hide();
        }
      }
    }
})