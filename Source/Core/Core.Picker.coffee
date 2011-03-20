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
    offset = @offset
    console.log offset
    x = ''
    y = ''
    if @position.x is 'auto' and @position.y is 'auto'
      if (position.x-size.x-winscroll.x) < 0
        x = 'right'
        xpos = position.x+asize.x+offset
      if (position.x+size.x+asize.x) > winsize.x
        x = 'left'
        xpos = position.x-size.x-offset
      if not ((position.x+size.x+asize.x)>winsize.x) and not ((position.x-size.x) < 0) 
        x = 'center'
        xpos = (position.x+asize.x/2)-(size.x/2)
      if position.y+size.y-winscroll.y > winsize.y
        y = 'up'
        ypos = position.y-size.y-offset
      else
        y = 'down'
        if x=='center'
          ypos = position.y+asize.y+offset
        else
          ypos = position.y
    if @position.x isnt 'auto'
      switch @position.x
        when 'left'
          xpos = position.x-size.x-offset
        when 'right'
          xpos = position.x+asize.x+offset
        when 'center'
          xpos = (position.x+asize.x/2)-(size.x/2)
          console.log xpos
    if @position.y isnt 'auto'
      switch @position.y
        when 'top'
          ypos = position.y-size.y-offset
        when 'bottom'
          ypos = position.y+asize.y+offset
        when 'center'
          ypos = position.y
    @base.setStyles {
      left : xpos
      top : ypos
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
