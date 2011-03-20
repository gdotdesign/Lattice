###
---

name: Core.Picker

description: Data picker class.

license: MIT-style license.

requires: [Core.Abstract, GDotUI, Interfaces.Enabled, Interfaces.Children]

provides: [Core.Picker, outerClick]

...
###
( ->
  oldPrototypeStart = Drag::start
  Drag.prototype.start = ->
    window.fireEvent 'outer'
    oldPrototypeStart.run arguments, @
)()

Core.Picker = new Class {
  Extends: Core.Abstract
  Implements: [Interfaces.Enabled,Interfaces.Children]
  Binds: ['show'
          'hide']
  Attributes: {
    class: {
      value: GDotUI.Theme.Picker.class
    }
    offset: {
      value: GDotUI.Theme.Picker.offset
      setter: (value) ->
        value
    }
    position: {
      value: {x:'auto',y:'auto'}
    }
  }
  options:{
    event: GDotUI.Theme.Picker.event
    picking: GDotUI.Theme.Picker.picking
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.setStyle 'position', 'absolute'
  onReady: ->
    if not @base.hasChild @contentElement
       @addChild @contentElement
    winsize = window.getSize()
    winscroll = window.getScroll()
    asize = @attachedTo.getSize()
    position = @attachedTo.getPosition()
    size = @base.getSize()
    x = ''
    y = ''
    if @position.x is 'auto' and @position.y is 'auto'
      if (position.x+size.x+asize.x) > (winsize.x-winscroll.x)
        x = 'left'
      else
        x = 'right'
             
      if (position.y+size.y+asize.y) > (winsize.y-winscroll.y)
        y = 'top'
      else
        y = 'bottom'

      if not ((position.y+size.y+asize.y) > (winsize.y-winscroll.y)) and not ((position.y-size.y) < 0)
        y = 'center'
      
      position = {x:x,y:y}
    else
      position = @position
    
    ofa = {}
                    
    switch position.x
      when 'center'
        ofa.x = -size.x/2
      when 'left'
        ofa.x = -(@offset+size.x)
      when 'right'
        ofa.x = @offset
    switch position.y
      when 'center'
        ofa.y = -size.y/2
      when 'top'
        ofa.y = -(@offset+size.y)
      when 'bottom'
        ofa.y = @offset

    @base.position {
      relativeTo: @attachedTo
      position: position
      offset: ofa
    }
  detach: ->
    if @contentElement?
      @contentElement.removeEvents 'change'
    if @attachedTo?
      @attachedTo.removeEvent @options.event, @show
      @attachedTo = null
      @fireEvent 'detached'
  justAttach: (input)->
    if @attachedTo?
      @detach()
    @attachedTo = input
  justShow: ->
    document.getElement('body').grab @base
    @base.addEvent 'outerClick', @hide.bindWithEvent @
    @onReady()
  attach: (input) ->
    if @attachedTo?
      @detach()
    input.addEvent @options.event, @show
    if @contentElement?
      @contentElement.addEvent 'change', ((value) ->
        @attachedTo.set 'value', value
        @attachedTo.fireEvent 'change', value
      ).bindWithEvent @
    @attachedTo = input
  attachAndShow: (el, e, callback) ->
    @contentElement.readyCallback = callback
    @attach el
    @show e
  show: (e) ->
    document.getElement('body').grab @base
    if @attachedTo?
      @attachedTo.addClass @options.picking
    if e?
      if e.stop?
        e.stop()
    if @contentElement?
      @contentElement.fireEvent 'show'
    @base.addEvent 'outerClick', @hide.bindWithEvent @
    @onReady()
  forceHide: ->
    if @attachedTo?
      @attachedTo.removeClass @options.picking
    @base.dispose()
  hide: (e) ->
    if e?
      if @base.isVisible() and not @base.hasChild(e.target)
        if @attachedTo?
          @attachedTo.removeClass @options.picking
        #@detach()
        @base.dispose()
  setContent: (element) ->
    @contentElement = element
}
