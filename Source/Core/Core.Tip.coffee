###
---

name: Core.Tip

description: Tip class

license: MIT-style license.

requires: [Core.Abstract, GDotUI]

provides: Core.Tip

...
###
Core.Tip = new Class {
  Extends:Core.Abstract
  Implements: Interfaces.Enabled
  Binds:['enter'
         'leave']
  Attributes: {
    class: {
      value: GDotUI.Theme.Tip.class
    }
    label: {
      value: ''
    }
    zindex: {
      value: 1
    }
    delay: {
      value: 0
    }
    location: {
      value: {x:'center',y:'center'}
    }
    offset: {
      value: 0
    }
  }
  update: ->
    @base.setStyle 'z-index', @zindex
    @base.set 'html', @label
  create: ->
    @base.setStyle 'position', 'absolute'
    @update()
  attach: (item) ->
    if @attachedTo?
      @detach()
    document.id(item).addEvent 'mouseenter', @enter
    document.id(item).addEvent 'mouseleave', @leave
    @attachedTo = document.id(item)
  detach: (item) ->
    document.id(item).removeEvent 'mouseenter', @enter
    document.id(item).removeEvent 'mouseleave', @leave
    @attachedTo = null
  enter: ->
    if @enabled
      @over = true
      @id = ( ->
        if @over
          @show()
      ).bind(@).delay @delay
  leave: ->
    if @enabled
      if @id?
        clearTimeout(@id)
        @id = null
      @over = false
      @hide()
  ready: ->
    size = @base.getSize()
    offset = {x:0,y:0}
    switch @location.x
      when 'center'
        if @location.y isnt 'center'
          offset.x = -size.x/2
      when 'left'
        offset.x = -(@offset+size.x)
      when 'right'
        offset.x = @offset
    switch @location.y
      when 'center'
        if @location.x isnt 'center'
          offset.y = -size.y/2
      when 'top'
        offset.y = -(@offset+size.y)
      when 'bottom'
        offset.y = @offset
    @base.position {
      relativeTo: @attachedTo
      position: @location
      offset: offset
    }
  hide: ->
    @base.dispose()
  show: ->
    document.getElement('body').grab(@base)
}
