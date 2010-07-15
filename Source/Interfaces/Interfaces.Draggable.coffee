###
---

name: Interfaces.Draggable

description: Porived dragging for elements that implements this.

license: MIT-style license.

requires: 

provides: [Interfaces.Draggable, Drag.Float]

...
###
Drag.Float: new Class {
	Extends: Drag.Move
	initialize: (el,options) ->
		@parent el, options
	start: (event) ->
		if @options.target == event.target
			@parent event
}

Interfaces.Draggable: new Class {
  Implements: Options
  options:{
    draggable:false
  }
  _$Draggable: ->
    if @options.draggable
      if @handle==null
      	@handle: @base
      @drag: new Drag.Float @base, {target:@handle, handle:@handle}
      @drag.addEvent 'drop', (->
        @fireEvent 'dropped', this
        ).bindWithEvent this
}