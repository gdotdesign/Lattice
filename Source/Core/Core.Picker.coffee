###
---

name: Core.Picker

description: Data picker class.

license: MIT-style license.

requires: [Core.Abstract, GDotUI, Interfaces.Enabled, Interfaces.Children]

provides: [Core.Picker, outerClick]

...
###
Core.Picker = new Class {
  Extends: Core.Abstract
  Implements: [Interfaces.Enabled,Interfaces.Children]
  Binds: ['show','hide','delegate']
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
    event: {
      value: GDotUI.Theme.Picker.event
      setter: (value, old) ->
        value
    }
    content: {
      value: null
      setter: (value, old)->
        if old?
          if old["$events"]
            old.removeEvent 'change', @delegate
          @removeChild old
        @addChild value
        if value["$events"]
          value.addEvent 'change', @delegate
        value
    }
    picking: {
      value: GDotUI.Theme.Picker.picking
    }
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.setStyle 'position', 'absolute'
  ready: ->
    winsize = window.getSize()
    winscroll = window.getScroll()
    asize = @attachedTo.getSize()
    position = @attachedTo.getPosition()
    size = @base.getSize()
    x = ''
    y = ''
    if @position.x is 'auto' and @position.y is 'auto'
      if (position.x+size.x+asize.x) > (winsize.x-winscroll.x) then x = 'left' else x = 'right'          
      if (position.y+size.y+asize.y) > (winsize.y-winscroll.y) then y = 'top' else y = 'bottom'
      if not ((position.y+size.y/2) > (winsize.y-winscroll.y)) and not ((position.y-size.y) < 0) then y = 'center'    
      position = {x:x,y:y}
    else
      position = @position
    
    ofa = {}
                    
    switch position.x
      when 'center'
        if position.y isnt 'center'
          ofa.x = -size.x/2
      when 'left'
        ofa.x = -(@offset+size.x)
      when 'right'
        ofa.x = @offset
    switch position.y
      when 'center'
        if position.x isnt 'center'
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
  attach: (el,auto) ->
    auto = if !auto? then true else auto
    if @attachedTo?
      @detach()
    @attachedTo = el
    if auto
      el.addEvent @event, @show
  detach: ->
    if @attachedTo?
      @attachedTo.removeEvent @event, @show
      @attachedTo = null
  delegate: ->
    if @attachedTo?
      @attachedTo.fireEvent 'change', arguments
  show: (e) ->
    document.body.grab @base
    if @attachedTo?
      @attachedTo.addClass @picking
    if e? then if e.stop? then  e.stop()
    @base.addEvent 'outerClick', @hide
  hide: (e,force) ->
    if force?
      if @attachedTo?
          @attachedTo.removeClass @picking
        @base.dispose()
    else if e?
      if @base.isVisible() and not @base.hasChild(e.target)
        if @attachedTo?
          @attachedTo.removeClass @picking
        @base.dispose()
}
