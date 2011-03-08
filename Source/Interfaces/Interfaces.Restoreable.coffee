###
---

name: Interfaces.Restoreable

description: Interface to store and restore elements status and position after refresh.

license: MIT-style license.

provides: Interfaces.Restoreable

requires: [GDotUI]

...
###
Interfaces.Restoreable = new Class {
  Impelments:[Options]
  Binds: ['savePosition']
  options:{
    cookieID:null
  }
  _$Restoreable: ->
    @addEvent 'dropped', @savePosition
    if @options.resizeable
      @sizeDrag.addEvent 'complete', ( ->
        window.localStorage.setItem @options.cookieID+'.height', @scrollBase.getSize().y
      ).bindWithEvent @
  saveState: ->
    state = if @base.isVisible() then 'visible' else 'hidden'
    if @options.cookieID isnt null
      window.localStorage.setItem @options.cookieID + '.state', state
  savePosition: ->
    if @options.cookieID isnt null
      position = @base.getPosition()
      state = if @base.isVisible() then 'visible' else 'hidden'
      window.localStorage.setItem @options.cookieID + '.x', position.x
      window.localStorage.setItem @options.cookieID + '.y', position.y
      window.localStorage.setItem @options.cookieID + '.state', state
  loadPosition: (loadstate)->
    if @options.cookieID isnt null
      @base.setStyle 'top', window.localStorage.getItem(@.options.cookieID + '.y') + "px"
      @base.setStyle 'left', window.localStorage.getItem(@.options.cookieID + '.x') + "px"
      @scrollBase.setStyle 'height', window.localStorage.getItem(@.options.cookieID +'.height') + "px"
      if window.localStorage.getItem(@options.cookieID+'.x') is null
        @center()
      if window.localStorage.getItem(@.options.cookieID+'.state') == "hidden" 
        @hide()
}
