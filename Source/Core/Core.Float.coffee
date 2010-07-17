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
		classes:{
			controls: GDotUI.Theme.Float.controls
			content: GDotUI.Theme.Float.content
			handle: GDotUI.Theme.Float.topHandle
			bottom: GDotUI.Theme.Float.bottomHandle
		}
		iconOptions:GDotUI.Theme.Float.iconOptions
		icons:{
			remove: GDotUI.Theme.Icons.remove
			edit: GDotUI.Theme.Icons.edit
		}
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
		@base.adopt @controls
		@parent()
	create: ->
		@base.addClass @options.class
		@base.setStyle 'position', 'absolute'
		@base.setPosition {x:0,y:0}
		@base.toggleClass 'inactive'
		
		@controls:  new Element 'div', {class:@options.classes.controls}
		@content: new Element 'div', {'class':@options.classes.content}
		@handle: new Element 'div', {'class':@options.classes.handle}
		@bottom: new Element 'div', {'class':@options.classes.bottom}

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
		
		@close: new Core.Icon {image:@options.icons.remove}
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
		
		if $chk @options.scrollBase
			@scrollBase: @options.scrollBase
		else
			@scrollBase: @content
		
		@scrollBase.setStyle 'overflow', 'hidden'
		
		if @options.resizeable
			@base.grab @bottom
			@sizeDrag: new Drag @scrollBase, {handle:@bottom, modifiers:{x:'',y:'height'}}
			@sizeDrag.addEvent 'drag', @resize
		
		@base.addEvent 'mouseenter', @mouseEnter
		@base.addEvent 'mouseleave', @mouseLeave
	mouseEnter: ->
		@base.toggleClass 'active'
		@base.toggleClass 'inactive'
		$clear @iconsTimout
		$clear @sliderTimout
		if @showSlider
			@slider.show()
		@icons.show()
		@mouseisover: on
	mouseLeave: ->
		@base.toggleClass('active');
		@base.toggleClass('inactive');
		if not @scrolling
			if @showSlider
				@sliderTimout: @slider.hide.delay 200,@slider
		@iconsTimout: @icons.hide.delay 200,@icons
		@mouseisover: off
	resize: ->
		if @scrollBase.getScrollSize().y > @scrollBase.getSize().y
			if not @showSlider
				@showSlider: on
				if @mouseisover
					@slider.show()
		else
			if @showSlider
				@showSlider: off
				@slider.hide()
	show: ->
		if not @base.isVisible()
			document.getElement('body').grab @base
			if @options.overlay
				GDotUI.Misc.Overlay.show()
				@base.setStyle 'z-index', 801
	hide: ->
		@base.dispose()
	toggle: (el) ->
		if @base.isVisible()
			@hide el
		else
			@show el
	setContent: (element) -> 
		@contentElement: element
		@content.grab element.base
	center: ->
		@base.position()
}