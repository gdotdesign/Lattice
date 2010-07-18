###
---

name: Interfaces.Restoreable

description: Interface to store and restore elements status and position after refresh.

license: MIT-style license.

requires: 

provides: Interfaces.Restoreable

...
###
Interfaces.Restoreable: new Class {
  Impelments:[Options]
  Binds: ['savePosition']
  options:{
    useCookie:true
    cookieID:null
  }
  _$Restoreable: ->
    @base.addEventListener 'DOMNodeRemovedFromDocument', ( ->
      if $chk @options.cookieID
        if @options.useCookie
          Cookie.write @options.cookieID+'.state', 'hidden', {duration:GDotUI.Config.cookieDuration}
        else
          window.localStorage.setItem @options.cookieID+'.state', 'hidden'
    ).bindWithEvent(this), off
    @addEvent 'dropped', @savePosition
  savePosition: ->
    if $chk @options.cookieID
      position: @base.getPosition();
      state: if @base.isVisible() then 'visible' else 'hidden'
      if @options.useCookie
        Cookie.write @options.cookieID+'.x', position.x, {duration:GDotUI.Config.cookieDuration}
        Cookie.write @options.cookieID+'.y', position.y, {duration:GDotUI.Config.cookieDuration}
        Cookie.write @options.cookieID+'.state', state, {duration:GDotUI.Config.cookieDuration}
      else
        window.localStorage.setItem @options.cookieID+'.x', position.x
        window.localStorage.setItem @options.cookieID+'.y', position.y
        window.localStorage.setItem @options.cookieID+'.state', state
  loadPosition: ->
    if $chk @options.cookieID
      if @options.useCookie
        @base.setStyle 'top', Cookie.read(this.options.cookieID+'.y')+"px"
        @base.setStyle 'left', Cookie.read(this.options.cookieID+'.x')+"px"
        if Cookie.read(@options.cookieID+'.state') == "hidden"
          @hide();
      else
        @base.setStyle 'top', window.localStorage.getItem(this.options.cookieID+'.y')+"px"
        @base.setStyle 'left', window.localStorage.getItem(this.options.cookieID+'.x')+"px"
        if window.localStorage.getItem(this.options.cookieID+'.state') == "hidden" 
          @hide();
}