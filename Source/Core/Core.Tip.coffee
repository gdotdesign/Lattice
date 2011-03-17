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
  Binds:['enter'
         'leave']
  options:{
    class: GDotUI.Theme.Tip.class
    label: ""
    location: GDotUI.Theme.Tip.location
    offset: GDotUI.Theme.Tip.offset
    zindex: GDotUI.Theme.Tip.zindex
    delay: 0
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @base.setStyle 'position', 'absolute'
    @base.setStyle 'z-index', @options.tipZindex
    @base.set 'html', @options.label
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
    @over = true
    #if @attachedTo.enabled
    @id = ( ->
      if @over
        @show()
    ).bind(@).delay @options.delay
  leave: ->
    if @id?
      clearTimeout(@id)
      @id = null
    @over = false
    #if @attachedTo.enabled
    @hide()
  ready: ->
    p = @attachedTo.getPosition()
    s = @attachedTo.getSize()
    s1 = @base.getSize()
    switch @options.location.x
      when "left"
        @base.setStyle 'left', p.x-(s1.x+@options.offset)
      when "right"
        @base.setStyle 'left', p.x+(s.x+@options.offset)
      when "center"
        @base.setStyle 'left', p.x-s1.x/2+s.x/2
    switch @options.location.y
      when "top"
        @base.setStyle 'top', p.y-(s.y+@options.offset)
      when "bottom"
        @base.setStyle 'top', p.y+(s.y+@options.offset)
      when "center"
        @base.setStyle 'top', p.y-s1.y/2+s.y/2
  hide: ->
    @base.dispose()
  show: ->
    document.getElement('body').grab(@base)
}
