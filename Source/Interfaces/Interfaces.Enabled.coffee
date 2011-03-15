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
  supress: ->
    if @children?
      @children.each (item) ->
        if item.disable?
          item.supress()
    @enabled = off
  unsupress: ->
    if @children?
      @children.each (item) ->
        if item.enable?
          item.unsupress()
    @enabled = on
  enable: ->
    if @children?
      @children.each (item) ->
        if item.enable?
          item.unsupress()
    @enabled = on
    @base.removeClass 'disabled'
    @fireEvent 'enabled'
  disable: ->
    if @children?
      @children.each (item) ->
        if item.disable?
          item.supress()
    @enabled = off
    @base.addClass 'disabled'
    @fireEvent 'disabled'
}
