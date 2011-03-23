###
---

name: Core.PushGroup

description: PushGroup element.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Children
  - Interfaces.Enabled
  - Interfaces.Size

provides: Core.PushGroup

todo: setActive into set 'active'
...
###
Core.PushGroup = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Children
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: GDotUI.Theme.PushGroup.class
    }
  }
  update: ->
    buttonwidth = Math.floor(@size / @children.length)
    @children.each (btn) ->
      btn.set 'size', buttonwidth
    if last = @children.getLast()
      last.set 'size', @size-buttonwidth*(@children.length-1)
  initialize: (options) ->
    @active = null
    @parent options 
  setActive: (item) ->
    if @active isnt item
      @children.each (btn) ->
        if btn isnt item
          btn.off()
          btn.unsupress()
        else
          btn.on()
          btn.supress()
      @active = item
      @fireEvent 'change', item
  removeItem: (item) ->
    if @hasChild item
      item.removeEvents 'invoked'
      @removeChild item
  addItem: (item) ->
    if not @hasChild item
      item.set 'minSize', 0
      item.addEvent 'invoked', ( (it) ->
        @setActive it
        @fireEvent 'change', it
      ).bind @
      @addChild item
    @update()
}
