###
---

name: Core.PushGroup

description: PushGroup element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Enabled, Interfaces.Children, GDotUI]

provides: Core.PushGroup

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
    if @buttons.contains(item)
      item.removeEvents 'invoked'
      @removeChild item
  addItem: (item) ->
    if not @children.contains(item)
      item.set 'minSize', 0
      @addChild item
      item.addEvent 'invoked', ( (it) ->
        @setActive item
        @fireEvent 'change', it
      ).bind @
    @update()
}
