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
		@base.adopt @icons, @slider
		@icons.base.setStyle 'right', -6
		@icons.base.setStyle 'top', 0
		@slider.base.setStyle 'right', -(@slider.base.getSize().x)-6
		@slider.base.setStyle 'top', @icons.size.y
		@parent()
	create: ->
		@base.addClass @options.class
		@base.setStyle 'position', 'absolute'
		@base.setPosition {x:0,y:0}
		@base.toggleClass 'inactive'
		@content: new Element 'div', {'class':GDotUI.Theme.Float.baseClass}
		@handle: new Element 'div', {'class':GDotUI.Theme.Float.handleClass}
		@bottom: new Element 'div', {'class':GDotUI.Theme.Float.bottomHandleClass}

		@base.adopt @handle, @content

		@slider: new Core.Slider {scrollBase:@content}
		@slider.base.setStyle 'position', 'absolute'
		@slider.addEvent 'complete', ( ->
			@scrolling: off
		).bindWithEvent this
		@slider.addEvent 'change', ( ->
			@scrolling: on
		).bindWithEvent this
		
		@slider.hide();
		
		@icons: new Core.IconGroup GDotUI.Theme.Float.iconOptions
		@icons.base.setStyle 'position','absolute'
		@icons.base.addClass GDotUI.Theme.Float.iconsClass
		
		@close: new Core.Icon {'class':GDotUI.Theme.Float.closeClass}
		@close.addEvent 'invoked', ( ->
			@hide()
		).bindWithEvent this

		@edit: new Core.Icon {'class':GDotUI.Theme.Float.editClass}
		@edit.addEvent 'invoked', ( ->
			if not @contentElement?
				if not @contentElement.toggleEdit?
					@contentElement.toggleEdit()
				@fireEvent('edit')
		).bindWithEvent this
		
		if @options.closeable
			@icons.addIcon @close
		if @options.editable
			@icons.addIcon @edit
		
		@icons.hide
		
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