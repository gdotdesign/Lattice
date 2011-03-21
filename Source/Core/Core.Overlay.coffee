###
---

name: Core.Overlay

description: Overlay for modal dialogs and stuff.

license: MIT-style license.

requires: [Core.Abstract, GDotUI]

provides: Core.Overlay

...
###
Core.Overlay = new Class {
  Extends: Core.Abstract
  Impelments: Interfaces.Enabled
  Attributes: {
    class: {
      value: GDotUI.Theme.Overlay.class
    }
    zindex: {
      value: 0
      setter: (value) ->
        @base.setStyle 'z-index', value
        value
    }
  }
  initialize: (options) ->
    @parent options 
  create: ->
    @enabled = true
    @base.setStyles {
      position:"fixed"
      top:0
      left:0
      right:0
      bottom:0
    }
    @hide()
  show: ->
    if @enabled
      @base.show()
  hide: ->
    if @enabled
      @base.hide()
  toggle: ->
    if @enabled
      @base.toggle()
    
}
