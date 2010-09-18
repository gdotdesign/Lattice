###
---

name: Core.Slot

description: Generic icon element.

license: MIT-style license.

requires: [Core.Abstract, Iterable.List]

provides: Core.Slot

...
###
Core.Slot = new Class {
  Extends:Core.Abstract
  Binds:['check'
         'complete']
  Delegates:{
    'list':['addItem'
            'removeAll'
            'select']
  }
  options:{
    class:GDotUI.Theme.Slot.class
  }
  initilaize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @overlay = new Element 'div', {'text':' '}
    @overlay.addClass 'over'
    @list = new Iterable.List()
    @list.addEvent 'select', ((item) ->
      @update()
      @fireEvent 'change', item
    ).bindWithEvent this
    @base.adopt @list.base, @overlay
  check: (el,e) ->
    @dragging = on
    lastDistance = 1000
    lastOne = null
    @list.items.each( ( (item,i) ->
      distance = -item.base.getPosition(@base).y+@base.getSize().y/2
      if distance < lastDistance and distance > 0 and distance < @base.getSize().y/2
        @list.select item
    ).bind this )
  ready: -> 
    @parent()
    @base.setStyle 'overflow', 'hidden'
    @base.setStyle 'position', 'relative'
    @list.base.setStyle 'position', 'absolute'
    @list.base.setStyle 'top', '0'
    @base.setStyle 'width', @list.base.getSize().x
    @overlay.setStyle 'width', @base.getSize().x
    @overlay.addEvent 'mousewheel',( (e) ->
      e.stop();
      if @list.selected?
        index = @list.items.indexOf @list.selected
      else
        if e.wheel==1
          index = 0
        else
          index = 1
      if index+e.wheel >= 0 and index+e.wheel < @list.items.length 
        @list.select @list.items[index+e.wheel]
      if index+e.wheel < 0
        @list.select @list.items[@list.items.length-1]
      if index+e.wheel > @list.items.length-1
        @list.select @list.items[0]
    ).bindWithEvent this
    @drag = new Drag @list.base, {modifiers:{x:'',y:'top'},handle:@overlay}
    @drag.addEvent 'drag', @check
    @drag.addEvent 'beforeStart',( ->
      @list.base.setStyle '-webkit-transition-duration', '0s'
    ).bindWithEvent this
    @drag.addEvent 'complete', ( ->
      @dragging = off
      @update()
    ).bindWithEvent this
  update: ->
    if not @dragging
      @list.base.setStyle '-webkit-transition-duration', '0.3s' # get the property and store and retrieve it
      if @list.selected?
        @list.base.setStyle 'top',-@list.selected.base.getPosition(@list.base).y+@base.getSize().y/2-@list.selected.base.getSize().y/2
}
