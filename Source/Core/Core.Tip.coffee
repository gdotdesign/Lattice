###
---

name: Core.Tip

description: Tip class.... (TODO Description)

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Tip

...
###
Core.Tip: new Class {
  Extends:Core.Abstract
  Binds:['enter'
         'leave']
  options:{
    text:""
    location: {x:"left"
               y:"bottom"}
    offset:5
  }
  initialize: (options) ->
    @parent options
    @create();
    this
  create:  ->
    @base.addClass GDotUI.Theme.tipClass
    @base.setStyle 'position','absolute'
    @base.setStyle 'z-index', GDotUI.Config.tipZindex
    @base.set 'html', this.options.text
  attach: (item) ->
    if not @attachedTo?
      @detach()
    item.base.addEvent 'mouseenter', @enter
    item.base.addEvent 'mouseleave', @leave
    @attachedTo: item
  detach: (item) ->
    item.base.removeEvent 'mouseenter', @enter
    item.base.removeEvent 'mouseleave', @leave
    @attachedTo: null
  enter: ->
    if @attachedTo.enabled
      @showTip()
  leave: ->
    if @attachedTo.enabled
      this.hideTip()
  showTip: ->
    p: @attachedTo.base.getPosition()
    s: @attachedTo.base.getSize();
    document.getElement('body').grab(@base)
    s1: @base.measure ->
          @getSize()
    switch @options.location.x
      when "left"
        @tip.setStyle 'left', p.x+(s.x+this.options.offset)
      when "right"
        @tip.setStyle 'left', p.x+(s.x+this.options.offset)
      when "center"
        @tip.setStyle 'left', p.x-s1.x/2+s.x/2
    switch @options.location.y
      when "top"
        @tip.setStyle 'top', p.y-(s.y+this.options.offset)
      when "bottom"
        @tip.setStyle 'top', p.y+(s.y+this.options.offset)
      when "center"
        @tip.setStyle 'top', p.y-s1.y/2+s.y/2
  hideTip: ->
    @base.dispose()
}