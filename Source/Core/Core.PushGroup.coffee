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
    buttonwidth = Math.floor(@size / @buttons.length)
    @buttons.each (btn) ->
      btn.set 'size', buttonwidth
    if last = @buttons.getLast()
      last.set 'size', @size-buttonwidth*(@buttons.length-1)
  initialize: (options) ->
    @buttons = []
    @parent options 
  setActive: (item) ->
    @buttons.each (btn) ->
      if btn isnt item
        btn.off()
        btn.unsupress()
      else
        btn.on()
        btn.supress()
    @fireEvent 'change', item
  addItem: (item) ->
    if @buttons.indexOf(item) is -1
      @buttons.push item  
      item.set 'minSize', 0
      @addChild item
      item.addEvent 'invoked', ( (it) ->
        @setActive item
        @fireEvent 'change', it
      ).bind @
    @update()
}
