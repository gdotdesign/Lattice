###
---

name: Core.Picker

description: Data picker class.

license: MIT-style license.

requires: [Core.Abstract]

provides: [Core.Picker, outerClick]

...
###
( ->
  oldPrototypeStart: Drag.prototype.start
  Drag.prototype.start: ->
    window.fireEvent 'outer'
    oldPrototypeStart.run arguments, this
)()
Element.Events.outerClick: {
    base: 'mousedown'
    condition: (event) ->
      event.stopPropagation();
      off
    onAdd: (fn) ->
      window.addEvent 'click', fn
      window.addEvent 'outer', fn
    onRemove: (fn) ->
      window.removeEvent 'click', fn
      window.removeEvent 'outer', fn
};
Core.Picker: new Class {
  Extends: Core.Abstract
  Binds: ['show'
          'hide']
  options:{
    class: GDotUI.Theme.Picker.class
    offset: GDotUI.Theme.Picker.offset
    event: GDotUI.Theme.Picker.event
    picking: GDotUI.Theme.Picker.picking
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @base.setStyle 'position', 'absolute'
  ready: ->
    if not @base.hasChild @contentElement
       @base.grab @contentElement
    winsize: window.getSize()
    winscroll: window.getScroll()
    asize: @attachedTo.getSize()
    position: @attachedTo.getPosition()
    size: @base.getSize()
    offset: @options.offset
    x: ''
    y: ''
    if (position.x-size.x-winscroll.x) < 0
      x: 'right'
      xpos: position.x+asize.x+offset
    if (position.x+size.x+asize.x) > winsize.x
      x: 'left'
      xpos: position.x-size.x-offset
    if not ((position.x+size.x+asize.x)>winsize.x) and not ((position.x-size.x) < 0) 
      x: 'center'
      xpos: (position.x+asize.x/2)-(size.x/2)
    if position.y+size.y-winscroll.y > winsize.y
      y: 'up'
      ypos: position.y-size.y-offset
    else
      y: 'down'
      if x=='center'
        ypos: position.y+asize.y+offset
      else
        ypos: position.y
    @base.setStyles {
      'left':xpos
      'top':ypos
    }
  detach: ->
    @contentElement.removeEvents 'change'
    @attachedTo.removeEvent @options.event, @show
    @attachedTo: null
  attach: (input) ->
    if @attachedTo?
      @detach()
    input.addEvent @options.event, @show #bind???
    @contentElement.addEvent 'change', ((value) ->
      @attachedTo.set 'value', value
      @attachedTo.fireEvent 'change', value
    ).bindWithEvent @
    @attachedTo: input
  attachAndShow: (el, e) ->
    @attach el
    @show e
  show: (e) ->
    document.getElement('body').grab @base
    @attachedTo.addClass @options.picking
    e.stop()
    if @contentElement?
      @contentElement.fireEvent 'show'
    @base.addEvent 'outerClick', @hide.bindWithEvent @ #bind here too???
  hide: (e) ->
    if @base.isVisible() and not  @base.hasChild(e.target)
      @attachedTo.removeClass @options.picking
      @base.dispose()
  setContent: (element) ->
    @contentElement: element
}
