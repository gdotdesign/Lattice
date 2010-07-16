###
---

name: Core.Picker

description: 

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Picker

...
###
Element.Events.outerClick: {
    base: 'click'
    condition: (event) ->
      event.stopPropagation();
      off
    onAdd: (fn) ->
      window.addEvent 'click', fn
    onRemove: (fn) ->
      window.removeEvent 'click', fn
};
Core.Picker: new Class {
  Extends:Core.Abstract
  Binds: ['show'
          'hide']
  options:{
    class:GDotUI.Theme.Picker.class
    offset:GDotUI.Theme.Picker.offset
  }
  initialize: (options) ->
    @parent(options)
    this
  create: ->
    @base.addClass @options.class
    @base.setStyle 'position', 'absolute'
  ready: ->
    if not @base.hasChild @contentElement
       @base.grab @contentElement
    winsize: window.getSize()
    asize: @attachedTo.getSize()
    position: @attachedTo.getPosition()
    size: @base.getSize()
    offset: @options.offset;
    x: ''
    y: ''
    if (position.x-size.x) < 0
      x: 'right'
      xpos: position.x+asize.x+offset
    if (position.x+size.x+asize.x) > winsize.x
      x: 'left'
      xpos: position.x-size.x-offset
    if not ((position.x+size.x+asize.x)>winsize.x) and not ((position.x-size.x) < 0) 
      x: 'center'
      xpos: (position.x+asize.x/2)-(size.x/2)
    if position.y > (winsize.x/2)
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
  attach: (input) ->
    input.addEvent 'click', this.show #bind???
    @contentElement.addEvent 'change', ((value) ->
      @attachedTo.set 'value', value
      @attachedTo.fireEvent 'change', value
    ).bindWithEvent this
    @attachedTo=input
  show: (e) ->
    document.getElement('body').grab @base
    @attachedTo.addClass 'picking'
    e.stop()
    @base.addEvent 'outerClick', this.hide #bind here too???
  hide: ->
    if @base.isVisible()
      @attachedTo.removeClass 'picking'
      @base.dispose()
  setContent: (element) ->
    @contentElement: element
}