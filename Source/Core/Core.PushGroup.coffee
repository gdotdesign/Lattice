###
---

name: Core.PushGroup

description: Basic button element.

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
  ]
  options:{
    class: GDotUI.Theme.PushGroup.class
  }
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
  create: ->
    @base.addClass @options.class
  addItem: (item) ->
    if @buttons.indexOf(item) is -1
      @buttons.push item  
      @addChild item
      item.addEvent 'invoked', ( (it) ->
        @setActive item
        @fireEvent 'change', it
      ).bind @
      @base.setStyle 'width', Number.from(@base.getStyle('width'))+item.width
}
