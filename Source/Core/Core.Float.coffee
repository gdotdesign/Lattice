###
---

name: Core.Float

description: Core.Float is a "floating" panel, with controls. Think of it as a window, just more awesome.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Draggable, Interfaces.Restoreable, Core.Slider, Core.IconGroup]

provides: Core.Float

...
###
Core.Float: new Class {
	Extends:Core.Abstract
	Implements:[Interfaces.Draggable
							Interfaces.Restoreable]
	Binds:['resize'
				 'mouseEnter'
				 'mouseLeave'
				 'hide'
				 ]
	options:{
		classes:{
			class: GDotUI.Theme.Float.class
			controls: GDotUI.Theme.Float.controls
			content: GDotUI.Theme.Float.content
			handle: GDotUI.Theme.Float.topHandle
			bottom: GDotUI.Theme.Float.bottomHandle
			active: GDotUI.Theme.Global.active
			inactive: GDotUI.Theme.Global.inactive
		}
		iconOptions: GDotUI.Theme.Float.iconOptions
		icons:{
			remove: GDotUI.Theme.Icons.remove
			edit: GDotUI.Theme.Icons.edit
		}
		closeable: on
		resizeable: off
		editable: off
		draggable: on
		ghost: off
	}
	initialize: (options) ->
		@showSilder: off
		@parent options
	ready: ->
		@base.adopt @controls
		@content.grab @contentElement
		if @options.restoreable
			@loadPosition()
		else
			@base.position()
		if @scrollBase.getScrollSize().y > @scrollBase.getSize().y
					if not @showSlider
						@showSlider: on
						if @mouseisover
							@slider.show()
		@parent()
	create: ->
		@base.addClass @options.classes.class
		@base.setStyle 'position', 'fixed'
		@base.setPosition {x:0,y:0}
		@base.toggleClass @options.classes.inactive
		
		@controls:  new Element 'div', {class: @options.classes.controls}
		@content: new Element 'div', {'class': @options.classes.content}
		@handle: new Element 'div', {'class': @options.classes.handle}
		@bottom: new Element 'div', {'class': @options.classes.bottom}

		@base.adopt @handle, @content

		@slider: new Core.Slider {scrollBase:@content, range:[0,100], steps: 100}
		@slider.addEvent 'complete', ( ->
			@scrolling: off
		).bindWithEvent this
		@slider.addEvent 'change', ( ->
			@scrolling: on
		).bindWithEvent this
		
		@slider.hide()
		
		@icons: new Core.IconGroup @options.iconOptions
		@controls.adopt @icons, @slider
		
		@close: new Core.Icon {image: @options.icons.remove}
		@close.addEvent 'invoked', ( ->
			@hide()
		).bindWithEvent this

		@edit: new Core.Icon {image:@options.icons.edit}
		@edit.addEvent 'invoked', ( ->
			if @contentElement?
				if @contentElement.toggleEdit?
					@contentElement.toggleEdit()
				@fireEvent('edit')
		).bindWithEvent this
		
		if @options.closeable
			@icons.addIcon @close
		if @options.editable
			@icons.addIcon @edit
		
		@icons.hide()
		
		if @options.scrollBase? 
			@scrollBase: @options.scrollBase
		else
			@scrollBase: @content
		
		@scrollBase.setStyle 'overflow', 'hidden'
		
		if @options.resizeable
			@base.grab @bottom
			@sizeDrag: new Drag @scrollBase, {handle:@bottom, modifiers:{x:'',y:'height'}}
			@sizeDrag.addEvent 'drag', ( ->
				if @scrollBase.getScrollSize().y > @scrollBase.getSize().y
					if not @showSlider
						@showSlider: on
						if @mouseisover
							@slider.show()
				else
					if @showSlider
						@showSlider: off
						@slider.hide()
				).bindWithEvent @
		@base.addEvent 'mouseenter', ( ->
			@base.toggleClass @options.classes.active
			@base.toggleClass @options.classes.inactive
			$clear @iconsTimout
			$clear @sliderTimout
			if @showSlider
				@slider.show()
			@icons.show()
			@mouseisover: on ).bindWithEvent @
		@base.addEvent 'mouseleave', ( ->
			@base.toggleClass @options.classes.active
			@base.toggleClass @options.classes.inactive
			if not @scrolling
				if @showSlider
					@sliderTimout: @slider.hide.delay 200, @slider
			@iconsTimout: @icons.hide.delay 200, @icons
			@mouseisover: off ).bindWithEvent @
	show: ->
		document.getElement('body').grab @base
		@saveState()
	hide: ->
		@base.dispose()
		@saveState()
	toggle: (el) ->
		if @base.isVisible()
			@hide el
		else
			@show el
	setContent: (element) -> 
		@contentElement: element
	center: ->
		@base.position()
}
