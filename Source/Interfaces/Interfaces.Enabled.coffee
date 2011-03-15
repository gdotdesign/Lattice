###
---

name: Interfaces.Enabled

description: Provides enable and disable function to elements.

license: MIT-style license.

provides: Interfaces.Enabled

requires: [GDotUI]
...
###
Interfaces.Enabled = new Class {
  _$Enabled: ->
    @enabled = on
  enable: ->
    if @children?
      @children.each (item) ->
        if item.enable?
          item.enable()
    @enabled = on
    @base.removeClass 'disabled'
    @fireEvent 'enabled'
  disable: ->
    console.log @children
    if @children?
      @children.each (item) ->
        if item.disable?
          item.disable()
    @enabled = off
    @base.addClass 'disabled'
    @fireEvent 'disabled'
}
