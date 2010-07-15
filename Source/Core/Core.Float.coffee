###
---

name: Core.Float

description: 

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Draggable, Interfaces.Restoreable, Core.Slider]

provides: Core.Float

...
###
Core.Float: new Class {
  Extends:Core.Abstract
  Implements:[Interfaces.Draggable
              Interfaces.Restoreable]
  Binds:['resize','mouseEnter','mouseLeave','hide']
  options:{
   class:GDotUI.Theme.Float.class
	 overlay: off
	 closeable: on
	 resizeable: off
	 editable: off
  }
  initialize: (options) ->
    @parent(options)
    @showSilder: off
    this
  ready: ->
    @loadPosition()
    @base.grab @icons, @slider
}