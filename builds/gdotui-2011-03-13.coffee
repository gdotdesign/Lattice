###
---

name: GDotUI

description: G.UI

license: MIT-style license.

provides: GDotUI

...
###
###
---
description: Class Mutator. Exposes methods as its own by delegating specified method calls directly to specified elements within the Class.

license: MIT-style

authors:
- Kevin Valdek
- Perrin Westrich

requires:
  core/1.2.4:   '*'

provides:
  - Class.Delegates

...
###
Class.Mutators.Delegates = (delegations) ->
	self = @
	new Hash(delegations).each (delegates, target) ->
		$splat(delegates).each (delegate) ->
			self.prototype[delegate] = ->
				ret = @[target][delegate].apply @[target], arguments
				if ret is @[target] then @ else ret
Interfaces = {}
Core = {}
Data = {}
Iterable = {}
Pickers = {}
Forms = {}

if !GDotUI?
  GDotUI = {}

GDotUI.Config ={
    tipZindex: 100
    floatZindex: 0
    cookieDuration: 7*1000
}


###
---

name: Interfaces.Mux

description: Runs function which names start with _$ after initialization. (Initialization for interfaces)

license: MIT-style license.

provides: Interfaces.Mux

requires: [GDotUI]

...
###
Interfaces.Mux = new Class {
  mux: ->
    (new Hash @ ).each( ( (value,key) ->
      if (key.test(/^_\$/) && $type(value)=="function")
        value.run null, @
    ).bind @ )
}


###
---

name: Interfaces.Reflow

description: Some control functions.

license: MIT-style license.

provides: Interfaces.Reflow

requires: [GDotUI]

...
###
Interfaces.Reflow = new Class {
  Implements: Events
  createTemp: ->
    @sensor = new Element 'p'
    @sensor.setStyles {
      margin: 0,
      padding: 0,
      position: 'absolute',
      bottom: 0,
      right: 0,
      "z-index": -9999
    }
  pollReflow: ->
    @base.grab @sensor
    counter = 0  
    interval = setInterval ( ->
      if @sensor.offsetWidth > 2 or ++counter > 99
        console.log interval
        clearInterval interval
        @sensor.dispose()
        @ready()
    ).bind(@) , 20
    
}


###
---

name: Core.Abstract

description: Abstract base class for Core U.I. elements.

license: MIT-style license.

requires: [Interfaces.Mux, GDotUI, Interfaces.Reflow]

provides: Core.Abstract

...
###
#INK save nodedata to html file in a comment.

getCSS = (selector, property) ->
  #selector = "/\\.#{@get('class')}$/"
  ret = null
  checkStyleSheet = (stylesheet) ->
    if stylesheet.cssRules?
      $A(stylesheet.cssRules).each (rule) ->
        if rule.styleSheet?
          checkStyleSheet(rule.styleSheet)
        if rule.selectorText?
          if rule.selectorText.test(eval(selector))
            ret = rule.style.getPropertyValue(property)
  $A(document.styleSheets).each (stylesheet) ->
    checkStyleSheet(stylesheet)
  ret
###
(->
  Element.implement {
    inTheDom: ->
      if @parentNode
        if @parentNode.tagName.toLowerCase() is "html"
          true
        else
          $(@parentNode).inTheDom
      else
        false
    grab: (el, where) ->
      Element::grab.call(arguments, @)
      el.fireEvent 'addedToDom'
      @
    inject: (el, where) ->
      console.log @parent
      Element::inject.call(arguments, @)
      @fireEvent 'addedToDom'
      @
    adopt: ->
      elements = Array.flatten(arguments)
      elements.each (el) ->
        el.fireEvent 'addedToDom'
      Element::adopt.call(arguments, @)
      @
      
  }
)()
###
Core.Abstract = new Class {
  Implements:[Events
              Options
              Interfaces.Mux
              Interfaces.Reflow]
  initialize: (options) ->
    @setOptions options
    @base = new Element 'div'
    @create()
    #@createTemp()
    #@base.addEvent 'addedToDom', @ready.bindWithEvent @
    @mux()
    @
  create: ->
  ready: ->
    #@base.removeEvents 'addedToDom'
  toElement: ->
    @base
}


###
---

name: Interfaces.Controls

description: Some control functions.

license: MIT-style license.

provides: Interfaces.Controls

requires: [GDotUI]

...
###
Interfaces.Controls = new Class {
  hide: ->
    @base.setStyle 'opacity', 0
  show: -> 
    @base.setStyle 'opacity', 1
  toggle: ->
    if @base.getStyle ('opacity') is 0
      @show()
    else
      @hide()
}


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
    @enabled = on
    @base.removeClass 'disabled'
    @fireEvent 'enabled'
  disable: ->
    @enabled = off
    @base.addClass 'disabled'
    @fireEvent 'disabled'
}


###
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, Interfaces.Enabled, GDotUI]

provides: Core.Icon

...
###
Core.Icon = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  options:{
    image: null
    class: GDotUI.Theme.Icon.class
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    if @options.image?
      @base.setStyle 'background-image', 'url(' + @options.image + ')'
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [@, e]
    ).bindWithEvent @
}


###
---

name: Core.IconGroup

description: Icon group with 4 types of layout.

license: MIT-style license.

requires: [Core.Abstract, GDotUI]

provides: Core.IconGroup

...
###
Core.IconGroup = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Controls
  Binds: ['delegate']
  options: {
    mode: "horizontal" #horizontal / vertical / circular / grid
    spacing: {
      x: 0
      y: 0
    }
    startAngle: 0 #degree
    radius: 0 #degree
    degree: 360 #degree
    class: GDotUI.Theme.IconGroup.class
  }
  initialize: (options) ->
    @icons = []
    @parent options
  create: ->
    @base.setStyle 'position', 'relative'
    @base.addClass @options.class
  delegate: ->
    @fireEvent 'invoked', arguments
  addIcon: (icon) ->
    if @icons.indexOf icon is -1
      icon.addEvent 'invoked', @delegate
      @base.grab icon
      @icons.push icon
      yes
    else no
  #show: ->
  #  @base.setStyle 'display', 'block'
  #hide: ->
  #  @base.setStyle 'display', 'none'
  #toggle: ->
  #  if @base.getStyle('display') is 'none'
  #    @show()
  #  else
  #    @hide()
  removeIcon: (icon) ->
    index = @icons.indexOf icon
    if index isnt -1
      icon.removeEvent 'invoked', @delegate
      icon.base.dispose()
      @icons.splice index, 1
      yes
    else no
  ready: ->
    @positionIcons()
  positionIcons: ->
    x = 0
    y = 0
    @size = {x:0, y:0}
    spacing = @options.spacing
    switch @options.mode
      when 'grid'
        if @options.columns?
          columns = @options.columns
          rows = @icons.length / columns
        if @options.rows?
          rows = @options.rows
          columns = Math.round @icons.length/rows
        icpos = @icons.map (item,i) ->
          if i % columns == 0
            x = 0
            y = if i==0 then y else y+item.base.getSize().y+spacing.y
          else
            x = if i==0 then x else x+item.base.getSize().x+spacing.x
          @size.x = x+item.base.getSize().x
          @size.y = y+item.base.getSize().y
          {x:x, y:y}
      when 'linear'
        icpos = @icons.map ((item,i) ->
          x = if i==0 then x+x else x+spacing.x
          y = if i==0 then y+y else y+spacing.y
          @size.x = x+item.base.getSize().x
          @size.y = y+item.base.getSize().y
          {x:x, y:y}
          ).bind @
      when 'horizontal'
        icpos = @icons.map ((item,i) ->
          x = if i==0 then x+x else x+item.base.getSize().x+spacing.x
          y = if i==0 then y else y+spacing.y
          @size.x = x+item.base.getSize().x
          @size.y = item.base.getSize().y
          {x:x, y:y}
          ).bind @
      when 'vertical'
        icpos = @icons.map ((item,i) ->
          x = if i==0 then x else x+spacing.x
          y = if i==0 then y+y else y+item.base.getSize().y+spacing.y
          @size.x = item.base.getSize().x
          @size.y = y+item.base.getSize().y
          {x:x,y:y}
          ).bind @
      when 'circular'
        n = @icons.length
        radius = @options.radius
        startAngle = @options.startAngle
        ker = 2*@radius*Math.PI
        fok = @options.degree/n
        icpos = @icons.map (item,i) ->
          if i==0
            foks = startAngle * (Math.PI/180)
            x = Math.round radius * Math.sin(foks)
            y = -Math.round radius * Math.cos(foks)
          else
            x = Math.round radius * Math.sin(((fok * i) + startAngle) * (Math.PI/180))
            y = -Math.round radius * Math.cos(((fok * i) + startAngle) * (Math.PI/180))
          {x:x, y:y}
    @icons.each (item,i) ->
      item.base.setStyle 'top', icpos[i].y
      item.base.setStyle 'left', icpos[i].x
      item.base.setStyle 'position', 'absolute'
}


###
---

name: Core.Tip

description: Tip class

license: MIT-style license.

requires: [Core.Abstract, GDotUI]

provides: Core.Tip

...
###
Core.Tip = new Class {
  Extends:Core.Abstract
  Binds:['enter'
         'leave']
  options:{
    class: GDotUI.Theme.Tip.class
    label: ""
    location: GDotUI.Theme.Tip.location
    offset: GDotUI.Theme.Tip.offset
    zindex: GDotUI.Theme.Tip.zindex
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @base.setStyle 'position', 'absolute'
    @base.setStyle 'z-index', @options.tipZindex
    @base.set 'html', @options.label
  attach: (item) ->
    if @attachedTo?
      @detach()
    item.base.addEvent 'mouseenter', @enter
    item.base.addEvent 'mouseleave', @leave
    @attachedTo = item
  detach: (item) ->
    item.base.removeEvent 'mouseenter', @enter
    item.base.removeEvent 'mouseleave', @leave
    @attachedTo = null
  enter: ->
    if @attachedTo.enabled
      @show()
  leave: ->
    if @attachedTo.enabled
      @hide()
  ready: ->
    p = @attachedTo.base.getPosition()
    s = @attachedTo.base.getSize()
    s1 = @base.getSize()
    switch @options.location.x
      when "left"
        @base.setStyle 'left', p.x-(s1.x+@options.offset)
      when "right"
        @base.setStyle 'left', p.x+(s.x+@options.offset)
      when "center"
        @base.setStyle 'left', p.x-s1.x/2+s.x/2
    switch @options.location.y
      when "top"
        @base.setStyle 'top', p.y-(s.y+@options.offset)
      when "bottom"
        @base.setStyle 'top', p.y+(s.y+@options.offset)
      when "center"
        @base.setStyle 'top', p.y-s1.y/2+s.y/2
  hide: ->
    @base.dispose()
  show: ->
    document.getElement('body').grab(@base)
}


###
---

name: Core.Slider

description: Slider element for other elements.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, GDotUI]

provides: [Core.Slider, ResetSlider]

...
###
ResetSlider = new Class {
  Extends: Slider
  initialize: (element, knob, options) ->
    @parent element, knob, options
  setRange: (range) ->
    @min = if  $chk(range[0]) then range[0] else 0
    @max = if $chk(range[1]) then range[1] else @options.steps
    @range = @max - @min
    @steps = @options.steps || @full
    @stepSize = Math.abs(@range) / @steps
    @stepWidth = @stepSize * @full / Math.abs(@range) 
  draggedKnob: ->
    dir = if @range < 0 then -1 else 1
    position = @drag.value.now[this.axis]
    position = position.limit(-@options.offset, @full-@options.offset)
    @step = @min + dir * @toStep(position)
    @checkStep()
  toStep: (position) ->
    step = (position + @options.offset) * @stepSize / @full * @steps
    if @options.steps then step -= step % @stepSize else step
}
Core.Slider = new Class {
  Extends:Core.Abstract
  Implements:[ Interfaces.Controls ]
  Delegates:{ 'slider':[
    'set'
    'setRange'
  ]}
  options:{
    scrollBase: null
    reset: off
    steps: 0
    range: [0,0]
    mode: 'vertical'
    class: GDotUI.Theme.Slider.barClass
    knob: GDotUI.Theme.Slider.knobClass
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @base.addClass @options.mode
    @knob = (new Element 'div').addClass @options.knob
    @scrollBase = @options.scrollBase
    @base.grab @knob
  ready: ->
    if @options.reset 
      @slider = new ResetSlider @base, @knob, {
        mode: @options.mode
        steps: @options.steps
        range: @options.range
      }
      @slider.set 0
    else
      @slider = new Slider @base, @knob, {
        mode: @options.mode
        range: @options.range
        steps: @options.steps
      }
    @slider.addEvent 'complete', ((step) ->
      @fireEvent 'complete', step+''
    ).bindWithEvent @
    @slider.addEvent 'change', ((step)->
      if typeof(step) == 'object'
        step = 0
      @fireEvent 'change', step+''
      if @scrollBase?
        @scrollBase.scrollTop = (@scrollBase.scrollHeight-@scrollBase.getSize().y)/100*step
    ).bindWithEvent @
    @parent()
}


###
---

name: Interfaces.Draggable

description: Porived dragging for elements that implements it.

license: MIT-style license.

provides: [Interfaces.Draggable, Drag.Float, Drag.Ghost]

requires: [GDotUI]
...
###
Drag.Float = new Class {
	Extends: Drag.Move
	initialize: (el,options) ->
		@parent el, options
	start: (event) ->
		if @options.target == event.target
			@parent event
}
Drag.Ghost = new Class {
	Extends: Drag.Move
	options: {
	  opacity: 0.65
		pos: false
		remove: ''}
	start: (event) ->
		if not event.rightClick
			@droppables = $$(@options.droppables)
			@ghost()
			@parent(event)
	cancel: (event) ->
		if event
			@deghost()
		@parent(event)
	stop: (event) ->
		@deghost()
		@parent(event)
	ghost: ->
		@element = (@element.clone()
		).setStyles({
			'opacity': @options.opacity,
			'position': 'absolute',
			'z-index': 5003,
			'top': @element.getCoordinates()['top'],
			'left': @element.getCoordinates()['left']
			'-webkit-transition-duration': '0s'
		}).inject(document.body).store('parent', @element)
		@element.getElements(@options.remove).dispose()	
	deghost: ->
		e = @element.retrieve 'parent'
		newpos = @element.getPosition e.getParent()
		if @options.pos && @overed==null
			e.setStyles({
			'top': newpos.y,
			'left': newpos.x
			})
		@element.destroy();
		@element = e;
}
Interfaces.Draggable = new Class {
	Implements: Options
	options:{
		draggable: off
		ghost: off
		removeClasses: ''
	}
	_$Draggable: ->
		if @options.draggable
			if @handle == null
				@handle = @base
			if @options.ghost
				@drag = new Drag.Ghost @base, {target:@handle, handle:@handle, remove:@options.removeClasses, droppables: @options.droppables, precalculate: on}
			else
				@drag = new Drag.Float @base, {target:@handle, handle:@handle}
			@drag.addEvent 'drop', (->
				@fireEvent 'dropped', arguments
			).bindWithEvent @
}


###
---

name: Interfaces.Restoreable

description: Interface to store and restore elements status and position after refresh.

license: MIT-style license.

provides: Interfaces.Restoreable

requires: [GDotUI]

...
###
Interfaces.Restoreable = new Class {
  Impelments:[Options]
  Binds: ['savePosition']
  options:{
    cookieID:null
  }
  _$Restoreable: ->
    @addEvent 'dropped', @savePosition
    if @options.resizeable
      @sizeDrag.addEvent 'complete', ( ->
        window.localStorage.setItem @options.cookieID+'.height', @scrollBase.getSize().y
      ).bindWithEvent @
  saveState: ->
    state = if @base.isVisible() then 'visible' else 'hidden'
    if @options.cookieID isnt null
      window.localStorage.setItem @options.cookieID + '.state', state
  savePosition: ->
    if @options.cookieID isnt null
      position = @base.getPosition()
      state = if @base.isVisible() then 'visible' else 'hidden'
      window.localStorage.setItem @options.cookieID + '.x', position.x
      window.localStorage.setItem @options.cookieID + '.y', position.y
      window.localStorage.setItem @options.cookieID + '.state', state
  loadPosition: (loadstate)->
    if @options.cookieID isnt null
      @base.setStyle 'top', window.localStorage.getItem(@.options.cookieID + '.y') + "px"
      @base.setStyle 'left', window.localStorage.getItem(@.options.cookieID + '.x') + "px"
      @scrollBase.setStyle 'height', window.localStorage.getItem(@.options.cookieID +'.height') + "px"
      if window.localStorage.getItem(@options.cookieID+'.x') is null
        @center()
      if window.localStorage.getItem(@.options.cookieID+'.state') == "hidden" 
        @hide()
}


###
---

name: Core.Float

description: Core.Float is a "floating" panel, with controls. Think of it as a window, just more awesome.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Draggable, Interfaces.Restoreable, Core.Slider, Core.IconGroup, GDotUI]

provides: Core.Float

...
###
Core.Float = new Class {
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
		overlay: off
	}
	initialize: (options) ->
		@showSilder = off
		@readyr = no
		@parent options
	ready: ->
		@base.adopt @controls
		if @contentElement?
			@content.grab @contentElement
		if @options.restoreable
			@loadPosition()
		else
			@base.position()
		if @scrollBase.getScrollSize().y > @scrollBase.getSize().y
					if not @showSlider
						@showSlider = on
						if @mouseisover
							@slider.show()
		@parent()
		@readyr = yes
	create: ->
		@base.addClass @options.classes.class
		@base.setStyle 'position', 'fixed'
		@base.setPosition {x:0,y:0}
		@base.toggleClass @options.classes.inactive
		
		@controls =  new Element 'div', {class: @options.classes.controls}
		@content = new Element 'div', {'class': @options.classes.content}
		@handle = new Element 'div', {'class': @options.classes.handle}
		@bottom = new Element 'div', {'class': @options.classes.bottom}

		@base.adopt @handle, @content

		@slider = new Core.Slider {scrollBase:@content, range:[0,100], steps: 100}
		@slider.addEvent 'complete', ( ->
			@scrolling = off
		).bindWithEvent @
		@slider.addEvent 'change', ( ->
			@scrolling = on
		).bindWithEvent @
		
		@slider.hide()
		
		@icons = new Core.IconGroup @options.iconOptions
		@controls.adopt @icons, @slider
		
		@close = new Core.Icon {image: @options.icons.remove}
		@close.addEvent 'invoked', ( ->
			@hide()
		).bindWithEvent @

		@edit = new Core.Icon {image:@options.icons.edit}
		@edit.addEvent 'invoked', ( ->
			if @contentElement?
				if @contentElement.toggleEdit?
					@contentElement.toggleEdit()
				@fireEvent('edit')
		).bindWithEvent @
		
		if @options.closeable
			@icons.addIcon @close
		if @options.editable
			@icons.addIcon @edit
		
		@icons.hide()
		
		if @options.scrollBase? 
			@scrollBase = @options.scrollBase
		else
			@scrollBase = @content
		
		@scrollBase.setStyle 'overflow', 'hidden'
		
		if @options.resizeable
			@base.grab @bottom
			@sizeDrag = new Drag @scrollBase, {handle:@bottom, modifiers:{x:'',y:'height'}}
			@sizeDrag.addEvent 'drag', ( ->
				if @scrollBase.getScrollSize().y > @scrollBase.getSize().y
					if not @showSlider
						@showSlider = on
						if @mouseisover
							@slider.show()
				else
					if @showSlider
						@showSlider = off
						@slider.hide()
				).bindWithEvent @
				@scrollBase.addEvent 'mousewheel',( (e) ->
					@scrollBase.scrollTop = @scrollBase.scrollTop+e.wheel*12
					@slider.knob.setStyle 'top', (@scrollBase.scrollTop/@scrollBase.getScrollSize().y)*@slider.base.getSize().y
				).bindWithEvent @
		@base.addEvent 'mouseenter', ( ->
			@base.toggleClass @options.classes.active
			@base.toggleClass @options.classes.inactive
			$clear @iconsTimout
			$clear @sliderTimout
			if @showSlider
				@slider.show()
			@icons.show()
			@mouseisover = on ).bindWithEvent @
		@base.addEvent 'mouseleave', ( ->
			@base.toggleClass @options.classes.active
			@base.toggleClass @options.classes.inactive
			if not @scrolling
				if @showSlider
					@sliderTimout = @slider.hide.delay 200, @slider
			@iconsTimout = @icons.hide.delay 200, @icons
			@mouseisover = off ).bindWithEvent @
	  if @options.overlay
	  	@overlay = new Core.Overlay()
	show: ->
		if @options.overlay
			document.getElement('body').grab @overlay
			@overlay.show()
		document.getElement('body').grab @base
		@saveState()
	hide: ->
		if @options.overlay
			@overlay.base.dispose()
		@base.dispose()
		@saveState()
	toggle: (el) ->
		if @base.isVisible()
			@hide el
		else
			@show el
	setContent: (element) -> 
		@contentElement = element
		if @readyr
			@content.getChildren().dispose()
			@content.grab @contentElement
			if @scrollBase.getScrollSize().y > @scrollBase.getSize().y
				@showSlider = on
				if @mouseisover
					@slider.show()
			else
				@showSlider = off
				@slider.hide()
	center: ->
		@base.position()
}


###
---

name: Core.Button

description: Basic button element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Enabled, Interfaces.Controls, GDotUI]

provides: Core.Button

...
###
Core.Button = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  options:{
    image: GDotUI.Theme.Button.defaultIcon
    text: GDotUI.Theme.Button.defaultText
    class: GDotUI.Theme.Button.class
  }
  initialize: (options) ->
    @parent options 
  create: ->
    delete @base
    @base = new Element 'button'
    @base.addClass(@options.class).set 'text', @options.text
    @icon = new Core.Icon {image: @options.image}
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [@, e]
      ).bindWithEvent @
    @base.grab @icon
}


###
---

name: Core.Picker

description: Data picker class.

license: MIT-style license.

requires: [Core.Abstract, GDotUI]

provides: [Core.Picker, outerClick]

...
###
( ->
  oldPrototypeStart = Drag.prototype.start
  Drag.prototype.start = ->
    window.fireEvent 'outer'
    oldPrototypeStart.run arguments, @
)()
Element.Events.outerClick = {
    base: 'mousedown'
    condition: (event) ->
      event.stopPropagation()
      off
    onAdd: (fn) ->
      window.addEvent 'click', fn
      window.addEvent 'outer', fn
    onRemove: (fn) ->
      window.removeEvent 'click', fn
      window.removeEvent 'outer', fn
}
Core.Picker = new Class {
  Extends: Core.Abstract
  Binds: ['show'
          'hide']
  options:{
    class: GDotUI.Theme.Picker.class
    offset: GDotUI.Theme.Picker.offset
    event: GDotUI.Theme.Picker.event
    picking: GDotUI.Theme.Picker.picking
  }
  initialize: (options) ->
    @parent options
    @
  create: ->
    @base.addClass @options.class
    @base.setStyle 'position', 'absolute'
  ready: ->
    if not @base.hasChild @contentElement
       @base.grab @contentElement
    winsize = window.getSize()
    winscroll = window.getScroll()
    asize = @attachedTo.getSize()
    position = @attachedTo.getPosition()
    size = @base.getSize()
    offset = @options.offset
    x = ''
    y = ''
    if (position.x-size.x-winscroll.x) < 0
      x = 'right'
      xpos = position.x+asize.x+offset
    if (position.x+size.x+asize.x) > winsize.x
      x = 'left'
      xpos = position.x-size.x-offset
    if not ((position.x+size.x+asize.x)>winsize.x) and not ((position.x-size.x) < 0) 
      x = 'center'
      xpos = (position.x+asize.x/2)-(size.x/2)
    if position.y+size.y-winscroll.y > winsize.y
      y = 'up'
      ypos = position.y-size.y-offset
    else
      y = 'down'
      if x=='center'
        ypos = position.y+asize.y+offset
      else
        ypos = position.y
    @base.setStyles {
      left : xpos
      top : ypos
    }
  detach: ->
    if @contentElement?
      @contentElement.removeEvents 'change'
    if @attachedTo?
      @attachedTo.removeEvent @options.event, @show
      @attachedTo = null
      @fireEvent 'detached'
  attach: (input) ->
    if @attachedTo?
      @detach()
    input.addEvent @options.event, @show
    if @contentElement?
      @contentElement.addEvent 'change', ((value) ->
        @attachedTo.set 'value', value
        @attachedTo.fireEvent 'change', value
      ).bindWithEvent @
    @attachedTo = input
  attachAndShow: (el, e, callback) ->
    @contentElement.readyCallback = callback
    @attach el
    @show e
  show: (e) ->
    document.getElement('body').grab @base
    if @attachedTo?
      @attachedTo.addClass @options.picking
    if e.stop?
      e.stop()
    if @contentElement?
      @contentElement.fireEvent 'show'
    @base.addEvent 'outerClick', @hide.bindWithEvent @
  hide: (e) ->
    if @base.isVisible() and not @base.hasChild(e.target)
      if @attachedTo?
        @attachedTo.removeClass @options.picking
        #@detach()
      @base.dispose()
  setContent: (element) ->
    @contentElement = element
}


###
---

name: Iterable.List

description: List element, with editing and sorting.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.List

requires: [GDotUI]
...
###
Iterable.List = new Class {
  Extends:Core.Abstract
  options:{
    class: GDotUI.Theme.List.class
    selected: GDotUI.Theme.List.selected
    search: off
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @sortable = new Sortables null
    @editing = off
    if @options.search
      @sinput = new Element 'input', {class:'search'}
      @base.grab @sinput
      @sinput.addEvent 'keyup', ( ->
          @search()
      ).bindWithEvent @
    @items = []
  search: ->
    svalue = @sinput.get 'value'
    @items.each ( (item) ->
      if item.title.get('text').test(/#{svalue}/ig) or item.subtitle.get('text').test(/#{svalue}/ig)
        item.base.setStyle 'display', 'block'
      else
        item.base.setStyle 'display', 'none'
    ).bind @
  removeItem: (li) ->
    li.removeEvents 'invoked', 'edit', 'delete'
    @items.erase li
    li.base.destroy()
  removeAll: ->
    if @options.search
      @sinput.set 'value', ''
    @selected = null
    @items.each ( (item) ->
      @removeItem item
      ).bind @
    delete @items
    @items = []
  toggleEdit: ->
    bases = @items.map (item) ->
      return item.base
    if @editing
      @sortable.removeItems bases
      @items.each (item) ->
        item.toggleEdit()
      @editing = off
    else
      @sortable.addItems bases
      @items.each (item) ->
        item.toggleEdit()
      @editing = on
  getItemFromTitle: (title) ->
    filtered = @items.filter (item) ->
      if item.title.get('text') == String(title)
        yes
      else no
    filtered[0]
  select: (item) ->
    if @selected != item
      if @selected?
        @selected.base.removeClass @options.selected
      @selected = item
      @selected.base.addClass @options.selected
      @fireEvent 'select', item
  updateWidth: (item) ->
    if !@width?
      width = getCSS("/\\.#{item.options.classes.class}$/","width")
      @width = width
  addItem: (li) -> 
    @items.push li
    @base.grab li
    li.addEvent 'select', ( (item)->
      @select item
      ).bindWithEvent @
    li.addEvent 'invoked', ( (item) ->
      @fireEvent 'invoked', arguments
      ).bindWithEvent @
    li.addEvent 'edit', ( -> 
      @fireEvent 'edit', arguments
      ).bindWithEvent @
    li.addEvent 'delete', ( ->
      @fireEvent 'delete', arguments
      ).bindWithEvent @
    @updateWidth li
}


###
---

name: Core.Slot

description: iOs style slot control.

license: MIT-style license.

requires: [Core.Abstract, Iterable.List, GDotUI]

provides: Core.Slot

...
###
Core.Slot = new Class {
  Extends: Core.Abstract
  Binds:['check'
         'complete']
  Delegates:{
    'list':['addItem'
            'removeAll'
            'select']
  }
  options:{
    class: GDotUI.Theme.Slot.class
  }
  initilaize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @overlay = new Element 'div', {'text':' '}
    @overlay.addClass 'over'
    @list = new Iterable.List()
    @list.addEvent 'select', ((item) ->
      @update()
      @fireEvent 'change', item
    ).bindWithEvent @
    @base.adopt @list.base, @overlay
  check: (el,e) ->
    @dragging = on
    lastDistance = 1000
    lastOne = null
    @list.items.each( ( (item,i) ->
      distance = -item.base.getPosition(@base).y + @base.getSize().y/2
      if distance < lastDistance and distance > 0 and distance < @base.getSize().y/2
        @list.select item
    ).bind @ )
  ready: ->
    @base.setStyle 'overflow', 'hidden'
    @base.setStyle 'position', 'relative'
    @list.base.setStyle 'position', 'absolute'
    @list.base.setStyle 'top', '0'
    @width = @list.width
    @base.setStyle 'width', @width
    @overlay.setStyle 'width', @width
    @overlay.addEvent 'mousewheel',( (e) ->
      e.stop()
      if @list.selected?
        index = @list.items.indexOf @list.selected
      else
        if e.wheel==1
          index = 0
        else
          index = 1
      if index+e.wheel >= 0 and index+e.wheel < @list.items.length 
        @list.select @list.items[index+e.wheel]
      if index+e.wheel < 0
        @list.select @list.items[@list.items.length-1]
      if index+e.wheel > @list.items.length-1
        @list.select @list.items[0]
    ).bindWithEvent @
    @drag = new Drag @list.base, {modifiers:{x:'',y:'top'},handle:@overlay}
    @drag.addEvent 'drag', @check
    @drag.addEvent 'beforeStart',( ->
      @list.base.setStyle '-webkit-transition-duration', '0s'
    ).bindWithEvent @
    @drag.addEvent 'complete', ( ->
      @dragging = off
      @update()
    ).bindWithEvent @
    @update()
  update: ->
    if not @dragging
      @list.base.setStyle '-webkit-transition-duration', '0.3s' # get the property and store and retrieve it
      if @list.selected?
        @list.base.setStyle 'top',-@list.selected.base.getPosition(@list.base).y+@base.getSize().y/2-@list.selected.base.getSize().y/2
}


###
---

name: Core.Tab

description: Tab element for Core.Tabs.

license: MIT-style license.

requires: [Core.Abstract, GDotUI]

provides: Core.Tab

...
###
Core.Tab = new Class {
  Extends: Core.Abstract
  options:{
    class: GDotUI.Theme.Tab.class
    label: ''
    image: GDotUI.Theme.Icons.remove
    active: GDotUI.Theme.Global.active
    removeable: off
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @base.addEvent 'click', ( ->
      @fireEvent 'activate', @
    ).bindWithEvent @
    @label = new Element 'div', {text: @options.label}
    @icon = new Core.Icon {image: @options.image}
    @icon.addEvent 'invoked', ( (ic,e) ->
      e.stop()
      @fireEvent 'remove', @
    ).bindWithEvent @
    @base.adopt @label
    if @options.removeable
      @base.grab @icon
  activate: ->
    @fireEvent 'activated', @
    @base.addClass @options.active 
  deactivate: ->
    @fireEvent 'deactivated', @
    @base.removeClass @options.active
}


###
---

name: Core.Tabs

description: Tab navigation element.

license: MIT-style license.

requires: [Core.Abstract, Core.Tab, GDotUI]

provides: Core.Tabs

...
###
Core.Tabs = new Class {
  Extends: Core.Abstract
  Binds:['remove','change']
  options:{
    class: GDotUI.Theme.Tabs.class
    autoRemove: on
  }
  initialize: (options) ->
    @tabs = []
    @active = null
    @parent options
  create: ->
    @base.addClass @options.class
  add: (tab) ->
    if @tabs.indexOf tab == -1
      @tabs.push tab
      @base.grab tab
      tab.addEvent 'remove', @remove
      tab.addEvent 'activate', @change
  remove: (tab) ->
    if @tabs.indexOf tab != -1
      if @options.autoRemove
        @removeTab tab
      @fireEvent 'removed',tab
  removeTab: (tab) ->
    @tabs.erase tab
    document.id(tab).dispose()
    if tab is @active
      if @tabs.length > 0
        @change @tabs[0]
    @fireEvent 'tabRemoved', tab
  change: (tab) ->
    if tab isnt @active
      @setActive tab
      @fireEvent 'change', tab
  setActive: (tab) ->
    if @active isnt tab
      if @active?
        @active.deactivate()
      tab.activate()
      @active = tab
  getByLabel: (label) ->
    (@tabs.filter (item, i) ->
      if item.options.label is label
        true
      else
        false)[0]
}


###
---

name: Core.TabFloat

description: Tabbed float.

license: MIT-style license.

requires: [Core.Float, Core.Tabs, GDotUI]

provides: Core.TabFloat

...
###
Core.TabFloat = new Class {
  Extends: Core.Float
  options: {
  }
  initialize: (options) ->
    @parent options
  create: ->
    @parent()
    @tabs = new Core.Tabs({class:'floatTabs'})
    @tabs.addEvent 'change', ( (tab) ->
      @lastTab = @tabs.tabs[@tabContents.indexOf(@activeContent)] 
      index = @tabs.tabs.indexOf tab
      @activeContent = @tabContents[index]
      @setContent @tabContents[index]
      @fireEvent 'tabChange'
      ).bindWithEvent @
    @tabContents = []
    @base.grab @tabs, 'top'
  addTab: (label,content) ->
    @tabs.add new Core.Tab({class:'floatTab',label:label})
    @tabContents.push content
  setContent: (element) ->
    index = null
    @tabContents.each (item,i) ->
      if item is element
        index = i
    if index?
      @tabs.setActive @tabs.tabs[index]
    @activeContent = @tabContents[index]
    @parent @tabContents[index]
}


###
---

name: Core.Toggler

description: iOs style checkboxes

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, Interfaces.Enabled, GDotUI]

provides: Core.Toggler

...
###
Element.Properties.checked = {
  get: ->
    if @getChecked?
      @getChecked()
  set: (value) ->
    @setAttribute 'checked', value
    if @on? and @off?
      if value
        @on()
      else
        @off()
}

Core.Toggler = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  options:{
    class: GDotUI.Theme.Toggler.class
    onClass: GDotUI.Theme.Toggler.onClass
    offClass: GDotUI.Theme.Toggler.offClass
    sepClass: GDotUI.Theme.Toggler.separatorClass
    onText: GDotUI.Theme.Toggler.onText
    offText: GDotUI.Theme.Toggler.offText
  }
  initialize: (options) ->
    @checked = yes
    @parent options
  create: ->
    @base.addClass @options.class
    @base.setStyle 'position','relative'
    @onLabel = new Element 'div', {text:@options.onText, class:@options.onClass}
    @onLabel.removeTransition()
    @offLabel = new Element 'div', {text:@options.offText, class:@options.offClass}
    @offLabel.removeTransition()
    @separator = new Element 'div', {html: '&nbsp;', class:@options.sepClass}
    @separator.removeTransition()
    @base.adopt @onLabel, @separator, @offLabel
    @base.getChecked = ( ->
      @checked
      ).bind @
    @base.on = @on.bind @
    @base.off = @off.bind @
  ready: ->
    $$(@onLabel,@offLabel,@separator).setStyles {
      'position':'absolute'
      'top': 0
      'left': 0
    }
    if @checked
      @on()
    else
      @off()
    @base.addEvent 'click', ( ->
       if @checked
        @off()
        @base.fireEvent 'change'
       else
        @on()
        @base.fireEvent 'change'
    ).bind @
    @onLabel.addTransition()
    @offLabel.getPosition()
    @offLabel.addTransition()
    @separator.addTransition()
    @parent()
  on: ->
    @checked = yes
    @onLabel.setStyle 'left', 0
    @follow()
  off: ->
    @checked = no
    @onLabel.setStyle 'left', -@onLabel.getSize().x
    @follow()
  follow: ->
    left = @onLabel.getStyle('left')
    @separator.setStyle 'left', Number(left[0..left.length-3])+@onLabel.getSize().x
    @offLabel.setStyle 'left',Number(left[0..left.length-3])+@onLabel.getSize().x + @separator.getSize().x
}


###
---

name: Core.Textarea

description: Html from markdown.

license: MIT-style license.

requires: [Core.Abstract, GDotUI]

provides: Core.Textarea

...
###
Core.Textarea = new Class {
  Extends: Core.Abstract
  initialize: (options) ->
    @parent options
  create: ->
    @parent
}


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
  options: {
    class: GDotUI.Theme.Overlay.class
  }
  initialize: (options) ->
    @parent options 
  create: ->
    @base.setStyles {
      position:"fixed"
      top:0
      left:0
      right:0
      bottom:0
      opacity:0
      }
    @base.addClass @options.class
    @base.addEventListener 'webkitTransitionEnd', ((e) ->
      if e.propertyName == "opacity" and @base.getStyle('opacity') == 0
        @base.setStyle 'visiblity', 'hidden'
      ).bindWithEvent @
  hide: ->
    @base.setStyle 'opacity', 0
  show: ->
    @base.setStyles {
      visiblity: 'visible'
      opacity: 1
    }
}


###
---

name: Data.Abstract

description: Abstract base class for data elements.

license: MIT-style license.

requires: [GDotUI]

provides: Data.Abstract

...
###
Data.Abstract = new Class {
  Implements:[Events
              Options
              Interfaces.Reflow]
  options:{}
  initialize: (options) ->
    @setOptions options
    @base = new Element 'div'
    @createTemp()
    #@base.addEvent 'addedToDom', @pollReflow.bindWithEvent @
    @create()
    @
  create: ->
  ready: ->
  toElement: ->
    @base
  setValue: ->
  getValue: ->
    @value
}


###
---

name: Data.Text

description: Text data element.

license: MIT-style license.

requires: [Data.Abstract, GDotUI]

provides: Data.Text

...
###
Data.Text = new Class {
  Extends: Data.Abstract
  options: {
    class: GDotUI.Theme.Text.class
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @text = new Element 'textarea'
    @base.grab @text
    @addEvent 'show', ( ->
      @text.focus()
      ).bindWithEvent this
    @text.addEvent 'keyup',( (e) ->
      @fireEvent 'change', @text.get('value')
    ).bindWithEvent this
  getValue: ->
    @text.get('value')
  setValue: (text) ->
    @text.set('value',text);
}


###
---

name: Data.Number

description: Number data element.

license: MIT-style license.

requires: [Data.Abstract, Core.Slider, GDotUI]

provides: Data.Number

...
###
Data.Number = new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Number.class
    range: GDotUI.Theme.Number.range
    reset: GDotUI.Theme.Number.reset
    steps: GDotUI.Theme.Number.steps
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @text = new Element 'input', {'type':'text'}
    @slider = new Core.Slider {
      reset: @options.reset
      range: @options.range
      steps: @options.steps
      mode:'horizontal'
    }
  ready: ->
    @justSet = off
    @slider.knob.grab @text
    @base.adopt @slider
    @slider.knob.addEvent 'click', ( ->
      @text.focus()
    ).bindWithEvent @
    @slider.addEvent 'complete', ( (step) ->
      if @options.reset
        @slider.setRange [step-@options.steps/2, Number(step)+@options.steps/2]
      @slider.set step
      ).bindWithEvent @
    @slider.addEvent 'change', ( (step) ->
      if typeof(step) == 'object'
        @text.set 'value', 0
      else
        @text.set 'value', step
      if not @justSet
        @fireEvent 'change', step
      else
        @justSet = off
      ).bindWithEvent @
    @text.addEvent 'change', ( ->
      step = Number @text.get('value')
      if @options.reset
        @slider.setRange [step-@options.steps/2,Number(step)+@options.steps/2]
      @slider.set step
      @fireEvent 'change', step
    ).bindWithEvent @
    @text.addEvent 'mousewheel', ( (e) ->
      @slider.set Number(@text.get('value'))+e.wheel
    ).bindWithEvent @
    @parent()
  getValue: ->
    @slider.slider.step
  setValue: (step) ->
    @justSet = on
    if @options.reset
      @slider.setRange [step-@options.steps/2,Number(step)+@options.steps/2]
    @slider.set step
}


###
---

name: Forms.Input

description: Input elements for Forms.

license: MIT-style license.

requires: GDotUI

provides: Forms.Input

...
###
Forms.Input = new Class {
  Implements:[Events
              Options]
  options:{
    type: ''
    name: ''
  }
  initialize: (options) ->
    @setOptions options
    @base = new Element 'div'
    @create()
    @
  create: () ->
    delete @base  
    if (@options.type is 'text' or @options.type is 'password' or @options.type is 'button')
      @base = new Element 'input', { type: @options.type, name: @options.name}
    if @options.type is 'checkbox'
      tg = new Core.Toggler()
      tg.base.setAttribute 'name', @options.name
      tg.base.setAttribute 'type', 'checkbox'
      tg.checked = @options.checked || false
      @base = tg.base
    if @options.type is "textarea"
      @base = new Element 'textarea', {name: @options.name}
    if @options.type is "select"
      @base = new Element 'select', {name: @options.name}
      @options.options.each ( (item) ->
        @base.grab new Element('option', {value:item.value,text:item.label})
      ).bind @
    if @options.type is "radio"
      @base = new Element 'div'
      @options.options.each ( (item,i) ->
        label = new Element 'label', {'text':item.label}
        input = new Element 'input', {type:'radio',name:@options.name, value:item.value}
        @base.adopt label, input
        ).bind @
    if @options.validate?
      $splat(@options.validate).each ( (val) ->
        if @options.type isnt "radio"
          @base.addClass val
      ).bind @
    @base
  toElement: ->
    @base
}


###
---

name: Data.Color

description: Color data element. ( color picker )

license: MIT-style license.

requires: [Data.Abstract, Forms.Input, GDotUI]

provides: Data.Color

...
###
Data.Color = new Class {
  Extends:Data.Abstract
  Binds: ['change']
  options:{
    class: GDotUI.Theme.Color.class
    sb: GDotUI.Theme.Color.sb
    hue: GDotUI.Theme.Color.hue 
    wrapper: GDotUI.Theme.Color.wrapper
    white: GDotUI.Theme.Color.white
    black: GDotUI.Theme.Color.black
    format: GDotUI.Theme.Color.format
  }
  initialize: (options) ->
    @parent(options)

    @angle = 0
    @radius = 0    
    
    #color
    @hue = 0
    @saturation = 0
    @brightness = 100
    
    @center = {}
    @size = {}
    
    @
  create: ->
    @base.addClass @options.class
    
    @hslacone = $(document.createElement('canvas'))
    @background = $(document.createElement('canvas'))
    @wrapper = new Element('div').addClass @options.wrapper
   
    @knob=new Element('div').set 'id', 'xyknob'
    @knob.setStyles {
      'position':'absolute'
      'z-index': 1
      }
      
    @colorData = new Data.Color.SlotControls()
    @bgColor = new Color('#fff')
    @base.adopt @wrapper
    @hueN = @colorData.hue
    @saturationN = @colorData.saturation
    @lightness = @colorData.lightness
    @alpha = @colorData.alpha
    @hueN.addEvent 'change',( (step) ->
      if typeof(step) == "object"
        step = 0
      @setHue(step)
    ).bindWithEvent @
    @saturationN.addEvent 'change',( (step) ->
      @setSaturation step
    ).bindWithEvent @
    @lightness.addEvent 'change',( (step) ->
      @hslacone.setStyle 'opacity',step/100
      @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
    ).bindWithEvent @
    
  drawHSLACone: (width,brightness) ->
    ctx = @hslacone.getContext '2d'
    w2 = -width/2
    ang = width / 50
    angle = (1/ang)*Math.PI/180
    i = 0
    for i in [0..(360)*(ang)-1]
      c = $HSB(360+(i/ang),100,brightness)
      c1 = $HSB(360+(i/ang),0,brightness)
      grad = ctx.createLinearGradient(0,0,width/2,0)
      grad.addColorStop(0, c1.hex)
      grad.addColorStop(1, c.hex)
      ctx.strokeStyle = grad
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.lineTo(width/2,0)
      ctx.stroke()
      ctx.rotate(angle)
      
  ready: ->
    @width = @wrapper.getSize().y
    
    @background.setStyles {
      'background-color': "#000"
      '-webkit-border-radius': @width/2+"px"
      'position': 'absolute'
      'z-index': 0
    }
    
    @hslacone.setStyles {
      'position': 'absolute'
      'z-index': 1
    }
    
    @hslacone.set 'width', @width
    @hslacone.set 'height', @width
    @background.set 'width', @width
    @background.set 'height', @width
    
    @wrapper.adopt @background, @hslacone, @knob
    
    ctx = @hslacone.getContext '2d'
    ctx.translate @width/2, @width/2
    @drawHSLACone @width, 100
    
    @xy = new Drag.Move @knob
    
    @halfWidth = @width/2
    @size = @knob.getSize()
    @knob.setStyles {left:@halfWidth-@size.x/2, top:@halfWidth-@size.y/2}
    
    @center = {x: @halfWidth, y:@halfWidth}
    
    
    @xy.addEvent 'drag', ((el,e) ->
      position = el.getPosition(@wrapper)
      
      x = @center.x-position.x-@size.x/2
      y = @center.y-position.y-@size.y/2
      
      @radius = Math.sqrt(Math.pow(x,2)+Math.pow(y,2))
      @angle = Math.atan2(y,x)
      
      if @radius > @halfWidth
        el.setStyle 'top', -Math.sin(@angle)*@halfWidth-@size.y/2+@center.y
        el.setStyle 'left', -Math.cos(@angle)*@halfWidth-@size.x/2+@center.x
        @saturation = 100
      else
        sat =  Math.round @radius 
        @saturation = Math.round((sat/@halfWidth)*100)
      
      an = Math.round(@angle*(180/Math.PI))
      @hue = if an < 0 then 180-Math.abs(an) else 180+an
      @hueN.setValue @hue
      @saturationN.setValue @saturation
      @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
    ).bind @
   
    
    @colorData.readyCallback = @readyCallback
    @base.adopt @colorData
    
   
    
    @colorData.base.getElements( 'input[type=radio]').each ((item) ->
      item.addEvent 'click',( (e)->
        @type = @colorData.base.getElements( 'input[type=radio]:checked')[0].get('value')
        @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
      ).bindWithEvent @
    ).bind @
    
    @alpha.addEvent 'change',( (step) ->
      @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
    ).bindWithEvent @
    @parent()
  readyCallback: ->  
    @alpha.setValue 100
    @lightness.setValue 100
    @hue.setValue 0
    @saturation.setValue 0
    delete @readyCallback
  setHue: (hue) ->
    @angle = -((180-hue)*(Math.PI/180))
    @hue = hue
    @knob.setStyle 'top', -Math.sin(@angle)*@radius-@size.y/2+@center.y
    @knob.setStyle 'left', -Math.cos(@angle)*@radius-@size.x/2+@center.x
    @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
  setSaturation: (sat) ->
    @radius = sat
    @saturation = sat
    @knob.setStyle 'top', -Math.sin(@angle)*@radius-@size.y/2+@center.y
    @knob.setStyle 'left', -Math.cos(@angle)*@radius-@size.x/2+@center.x
    @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
  setValue: (color, alpha, type) ->
    @hue = color.hsb[0]
    @saturation = color.hsb[1]
    @angle = -((180-color.hsb[0])*(Math.PI/180))
    @radius = color.hsb[1]
    @knob.setStyle 'top', -Math.sin(@angle)*@radius-@size.y/2+@center.y
    @knob.setStyle 'left', -Math.cos(@angle)*@radius-@size.x/2+@center.x
    @hueN.setValue color.hsb[0]
    @saturationN.setValue color.hsb[1]
    @alpha.setValue alpha
    @lightness.setValue color.hsb[2]
    @hslacone.setStyle 'opacity',color.hsb[2]/100
    @colorData.base.getElements( 'input[type=radio]').each ((item) ->
      if item.get('value') == type
        item.set 'checked', true
    ).bind @
    @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()}
  setColor: ->
    @finalColor = $HSB(@hue,@saturation,100)
    type = 
    @fireEvent 'change', {color:@finalColor, type:type, alpha:@alpha.getValue()}
  getValue: ->
    @finalColor
  change: (pos) ->
    @saturation.slider.slider.detach()
    @saturation.setValue pos.x
    @saturation.slider.slider.attach()
    @lightness.slider.slider.detach()
    @lightness.setValue 100-pos.y
    @lightness.slider.slider.attach()
    @setColor()
}
Data.Color.ReturnValues = {
  type: 'radio'
  name: 'col'
  options: [
    {
      label: 'rgb'
      value: 'rgb'
    }
    {
      label: 'rgba'
      value: 'rgba'
    }
    {
      label: 'hsl'
      value: 'hsl'
    }
    {
      label: 'hsla'
      value: 'hsla'
    }
    {
      label: 'hex'
      value: 'hex'
    }
  ]
}
Data.Color.SlotControls = new Class {
  Extends:Data.Abstract
  options:{
    class:GDotUI.Theme.Color.controls.class
  }
  initialize: (options) ->
    @parent(options)
  create: ->
    @base.addClass @options.class  
    @hue = new Data.Number {range:[0,360],reset: off, steps: [360]}
    @hue.addEvent 'change', ((value) ->
        @saturation.slider.base.setStyle 'background-color', new $HSB(value,100,100)
      ).bindWithEvent @
    @saturation = new Data.Number {range:[0,100],reset: off, steps: [100]}
    @lightness = new Data.Number {range:[0,100],reset: off, steps: [100]}
    @alpha = new Data.Number {range:[0,100],reset: off, steps: [100]}
    @col = new Forms.Input Data.Color.ReturnValues
  ready: ->
    @base.adopt @hue, @saturation, @lightness, @alpha, @col
    @base.getElements('input[type=radio]')[0].set('checked',true)
    if @readyCallback?
      @readyCallback()
    @parent()
}


###
---

name: Data.Date

description: Date picker element with Core.Slot-s

license: MIT-style license.

requires: [Data.Abstract, Core.Slot, GDotUI]

provides: Data.Date

...
###
Data.Date = new Class {
  Extends: Data.Abstract
  options:{
    class: GDotUI.Theme.Date.class
    format: GDotUI.Theme.Date.format
    yearFrom: GDotUI.Theme.Date.yearFrom
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @days = new Core.Slot()
    @month = new Core.Slot()
    @years = new Core.Slot()
    @years.addEvent 'change', ( (item) ->
      @date.setYear item.value
      @setValue()
    ).bindWithEvent @
    @month.addEvent 'change', ( (item) ->
      @date.setMonth item.value
      @setValue()
    ).bindWithEvent @
    @days.addEvent 'change', ( (item) ->
      @date.setDate item.value
      @setValue()
    ).bindWithEvent @
    i = 0
    while i < 30
      item = new Iterable.ListItem {title:i+1}
      item.value = i+1
      @days.addItem item
      i++
    i = 0
    while i < 12
      item = new Iterable.ListItem {title:i+1}
      item.value = i
      @month.addItem item
      i++
    i = @options.yearFrom
    while i <= new Date().getFullYear()
      item = new Iterable.ListItem {title:i}
      item.value = i
      @years.addItem item
      i++
    @base.adopt @years, @month, @days
  ready: ->
    if not @date?
      @setValue new Date()
  getValue: ->
    @date.format(@options.format)
  setValue: (date) ->
    if date?
      @date = date
    @update()
    @fireEvent 'change', @date
  update: ->
    cdays = @date.get 'lastdayofmonth'
    listlength = @days.list.items.length
    if cdays > listlength
      i = listlength+1
      while i <= cdays
        item=new Iterable.ListItem {title:i}
        item.value = i
        @days.addItem item
        i++
    else if cdays < listlength
      i = listlength
      while i > cdays
        @days.list.removeItem @days.list.items[i-1]
        i--
    @days.select @days.list.items[@date.getDate()-1]
    @month.select @month.list.items[@date.getMonth()]
    @years.select @years.list.getItemFromTitle(@date.getFullYear())
}


###
---

name: Data.Time

description: Time picker element with Core.Slot-s

license: MIT-style license.

requires: [Data.Abstract, GDotUI]

provides: Data.Time

...
###
Data.Time = new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Date.Time.class
    format: GDotUI.Theme.Date.Time.format
  }
  initilaize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @hourList = new Core.Slot()
    @minuteList = new Core.Slot()
    @hourList.addEvent 'change', ( (item) ->
      @time.setHours item.value
      @setValue()
    ).bindWithEvent @
    @minuteList.addEvent 'change', ( (item) ->
      @time.setMinutes item.value
      @setValue()
    ).bindWithEvent @
    i = 0
    while i < 24
      item = new Iterable.ListItem {title:i}
      item.value = i
      @hourList.addItem item
      i++
    i = 0
    while i < 60
      item = new Iterable.ListItem {title: if i<10 then '0'+i else i}
      item.value = i
      @minuteList.addItem item
      i++
    @hourList.ready()
    @minuteList.ready()
    @base.adopt @hourList, @minuteList
    @setValue(@time or new Date())
  getValue: ->
    @time.format @options.format
  setValue: (date) ->
    if date?
      @time = date
    @hourList.select @hourList.list.items[@time.getHours()]
    @minuteList.select @minuteList.list.items[@time.getMinutes()]
    @fireEvent 'change', @time.format(@options.format)
}


###
---

name: Data.DateTime

description:  Date & Time picker element with Core.Slot-s

license: MIT-style license.

requires: [Data.Abstract, Data.Date, Data.Time, GDotUI]

provides: Data.DateTime

...
###
Data.DateTime = new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Date.DateTime.class
    format: GDotUI.Theme.Date.DateTime.format
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @datea = new Data.Date()
    @time = new Data.Time()
  ready: ->
    @base.adopt @datea, @time
    @setValue( @date or new Date())
    @datea.addEvent 'change',( ->
      @date.setYear @datea.date.getFullYear()
      @date.setMonth @datea.date.getMonth()
      @date.setDate @datea.date.getDate()
      @fireEvent 'change', @date
    ).bindWithEvent @
    @time.addEvent 'change',( ->
      @date.setHours @time.time.getHours()
      @date.setMinutes @time.time.getMinutes()
      @fireEvent 'change', @date
    ).bindWithEvent @
    @parent()
  getValue: ->
    @date.format(@options.format)
  setValue: (date) ->
    if date?
      @date = date
    @datea.setValue @date
    @time.setValue @date
    @fireEvent 'change', @date
}


###
---

name: Data.Table

description: Text data element.

requires: [Data.Abstract, GDotUI]

provides: Data.Table

...
###
checkForKey = (key,hash,i) ->
  if not i?
    i = 0
  if not hash[key]?
    key
  else
    if not hash[key+i]?
      key+i
    else
      checkForKey key,hash,i+1
Data.Table = new Class {
  Extends: Data.Abstract
  Binds: ['update']
  options: {
    columns: 1
    class: GDotUI.Theme.Table.class
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @table = new Element 'table', {cellspacing:0, cellpadding:0}
    @base.grab @table
    @rows = []
    @columns = @options.columns
    @header = new Data.TableRow {columns:@columns}
    @header.addEvent 'next', ( ->
      @addCloumn ''
      @header.cells.getLast().editStart()
    ).bindWithEvent @
    @header.addEvent 'editEnd', ( ->
      @fireEvent 'change', @getData()
      if not @header.cells.getLast().editing
        if @header.cells.getLast().getValue() is ''
          @removeLast()
    ).bindWithEvent @
    @table.grab @header
    @addRow @columns
    @
  ready: ->
  addCloumn: (name) ->
    @columns++
    @header.add name
    @rows.each (item) ->
      item.add ''
  removeLast: () ->
    @header.removeLast()
    @columns--
    @rows.each (item) ->
      item.removeLast()
  addRow: (columns) ->
    row = new Data.TableRow({columns:columns})
    row.addEvent 'editEnd', @update
    row.addEvent 'next', ((row) ->
      index = @rows.indexOf row
      if index isnt @rows.length-1
        @rows[index+1].cells[0].editStart()
    ).bindWithEvent @
    @rows.push row
    @table.grab row
  removeRow: (row,erase) ->
    if not erase?
      erase = yes
    row.removeEvents 'editEnd'
    row.removeEvents 'next'
    row.removeAll()
    if erase
      @rows.erase row
    row.base.destroy()
    delete row
  removeAll: (addColumn) ->
    if not addColumn?
      addColumn = yes
    @header.removeAll()
    @rows.each ( (row) ->
      @removeRow row, no
    ).bind @
    @rows.empty()
    @columns = 0
    if addColumn
      @addCloumn()
      @addRow @columns
  update: ->
    length = @rows.length
    longest = 0
    rowsToRemove = []
    @rows.each ( (row, i) ->
      empty = row.empty() # check is the row is empty
      if empty
        rowsToRemove.push row
    ).bind @
    rowsToRemove.each ( (item) ->
      @removeRow item
    ).bind @
    if @rows.length is 0 or not @rows.getLast().empty()
      @addRow @columns
    @fireEvent 'change', @getData()
  getData: ->
    ret = {}
    headers = []
    @header.cells.each (item) ->
      value = item.getValue()        
      ret[checkForKey(value,ret)] =[]
      headers.push ret[value]
    @rows.each ( (row) ->
      if not row.empty()
        row.getValue().each (item,i) ->
          headers[i].push item
    ).bind @
    ret
  getValue: ->
    @getData()
  setValue: (obj) ->
    @removeAll( no )
    rowa = []
    j = 0
    self = @
    new Hash(obj).each (value,key) ->
      self.addCloumn key
      value.each (item,i) ->
        if not rowa[i]?
          rowa[i] = []
        rowa[i][j] = item
      j++
    rowa.each (item,i) ->
      self.addRow self.columns
      self.rows[i].setValue item
    @update()
    @
}
Data.TableRow = new Class {
  Extends: Data.Abstract
  Delegates: {base: ['getChildren']}
  options: {
    columns: 1
    class: ''
  }
  initialize: (options) ->
    @parent options
  create: ->
    delete @base
    @base = new Element 'tr'
    @base.addClass @options.class
    @cells = []
    i = 0
    while i < @options.columns
      @add('')
      i++
  add: (value) ->
    cell = new Data.TableCell({value:value})
    cell.addEvent 'editEnd', ( ->
      @fireEvent 'editEnd'
    ).bindWithEvent @
    cell.addEvent 'next', ((cell) ->
      index = @cells.indexOf cell
      if index is @cells.length-1
        @fireEvent 'next', @
      else
        @cells[index+1].editStart()
    ).bindWithEvent @
    @cells.push cell
    @base.grab cell
  empty: ->
    filtered = @cells.filter (item) ->
      if item.getValue() isnt '' then yes else no
    if filtered.length > 0 then no else yes
  removeLast: ->
    @remove @cells.getLast()
  remove: (cell,remove)->
    cell.removeEvents 'editEnd'
    cell.removeEvents 'next'
    @cells.erase cell
    cell.base.destroy()
    delete cell
  removeAll: ->
    (@cells.filter -> true).each ( (cell) ->
      @remove cell
    ).bind @
  getValue: ->
    @cells.map (cell) ->
      cell.getValue()
  setValue: (value) ->
    @cells.each (item,i) ->
      item.setValue value[i]
}
Data.TableCell = new Class {
  Extends: Data.Abstract
  Binds: ['editStart','editEnd']
  options:{
    editable: on
    value: ''
  }
  initialize: (options) ->
    @parent options
  create: ->
    delete @base
    @base = new Element 'td', {text: @options.value}
    @value = @options.value
    if @options.editable
      @base.addEvent 'click', @editStart
  editStart: ->
    if not @editing
      @editing = on
      @input = new Element 'input', {type:'text',value:@value}
      @base.set 'html', ''
      @base.grab @input
      @input.addEvent 'change', ( ->
        @setValue @input.get 'value'
      ).bindWithEvent @
      @input.addEvent 'keydown', ( (e) ->
        if e.key is 'enter'
          @input.blur()
        if e.key is 'tab'
          e.stop()
          @fireEvent 'next', @
      ).bindWithEvent @
      size = @base.getSize()
      @input.setStyles {width: size.x+"px !important",height:size.y+"px !important"}
      @input.focus()
      @input.addEvent 'blur', @editEnd
  editEnd: (e) ->
    if @editing
      @editing = off
    @setValue @input.get 'value'
    if @input?
      @input.removeEvents ['change','keydown']
      @input.destroy()
      delete @input
    @fireEvent 'editEnd'
  setValue: (value) ->
    @value = value
    if not @editing
      @base.set 'text', @value
  getValue: ->
    if not @editing
      @base.get 'text'
    else @input.get 'value'
}


###
---

name: Data.Select

description: Color data element. ( color picker )

license: MIT-style license.

requires: [Data.Abstract, GDotUI]

provides: Data.Select

...
###
Data.Select = new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Select.class
    list: {}
  }
  initialize: (options) ->
    @parent(options)
  create: ->
    @base.addClass @options.class
    @select = new Element 'select'
    @base.grab @select
    new Hash(@options.list).each ( (value,key) ->
      option = new Element 'option'
      option.set 'value', value
      option.set 'text', key
      @select.grab option
    ).bind @
    @select.addEvent 'change', ( ->
      @value = @select.get 'value'
      @fireEvent 'change', @value
    ).bindWithEvent @
  setList: (list) ->
    @select.getElements("option").destroy()
    new Hash(list).each ( (value,key) ->
      option = new Element 'option'
      option.set 'value', value
      option.set 'text', key
      @select.grab option
    ).bind @
  setValue: (value) ->
    selected = @select.getElements "option[value=#{value}]"
    if selected[0]?
      @select.getElements("option").set 'selected', null
      selected.set 'selected', true
      @value = value
  getValue: ->
    if not @value?
      @value = @select.get 'value'
    @value
}
    


###
---

name: Data.Unit

description: Color data element. ( color picker )

license: MIT-style license.

requires: [Data.Abstract, GDotUI]

provides: Data.Unit

...
###
UnitTable = {
  "px":{
    range:[-50,50]
    steps:[100]
  }
  "%":{
    range:[-50,50]
    steps:[100]
  }
  "em":{
    range:[-5,5]
    steps:[100]
  }
  "s":{
    range:[-10,10]
    steps:[100]
  }
  "default":{
    range:[-50,50]
    steps:[100]
  }
}
UnitList = {
  px: "px"
  '%': "%"
  em: "em"
  ex:"ex"
  gd:"gd"
  rem:"rem"
  vw:"vw"
  vh:"vh"
  vm:"vm"
  ch:"ch"
  "in":"in"
  mm:"mm"
  pt:"pt"
  pc:"pc"
  cm:"cm"
  deg:"deg"
  grad:"grad"
  rad:"rad"
  turn:"turn"
  s:"s"
  ms:"ms"
  Hz:"Hz"
  kHz:"kHz"
  }
Data.Unit = new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Unit.class
  }
  initialize: (options) ->
    @parent(options)
  create: ->
    @value = 0
    @base.addClass @options.class
    @number = new Data.Number {range:[-50,50],reset: on, steps: [100]}
    @sel = new Data.Select {list:UnitList}
    @number.addEvent 'change', ((value) ->
      @value = value
      @fireEvent 'change', String(@value)+@sel.getValue()
    ).bindWithEvent @
    @sel.setValue 'px'
    @sel.addEvent 'change', ( ->
      @fireEvent 'change', String(@value)+@sel.getValue()
    ).bindWithEvent @
    @base.adopt @number, @sel
  setValue: (value) ->
    if typeof value is 'string'
      match = value.match(/(-?\d*)(.*)/)
      value = match[1]
      unit = match[2]
      @sel.setValue unit
      @number.setValue value
  getValue: ->
    String(@value)+@sel.value
}
    


###
---

name: Data.List

description: Text data element.

requires: [Data.Abstract, GDotUI]

provides: Data.List

...
###
Data.List = new Class {
  Extends: Data.Abstract
  Binds: ['update']
  options: {
    class: GDotUI.Theme.DataList.class
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @table = new Element 'table', {cellspacing:0, cellpadding:0}
    @base.grab @table
    @cells = []
    @add ''
  update: ->
    @cells.each ((item) ->
      if item.getValue() is ''
        @remove item
      ).bind @
    if @cells.length is 0
      @add ''
    if @cells.getLast().getValue() isnt ''
      @add ''
    @fireEvent 'change', {value:@getValue()}
  add: (value) ->
    cell = new Data.TableCell({value:value})
    cell.addEvent 'editEnd', @update
    cell.addEvent 'next', ->
      cell.input.blur()
    @cells.push cell
    tr = new Element 'tr'
    @table.grab tr
    tr.grab cell
  remove: (cell,remove)->
    cell.removeEvents 'editEnd'
    cell.removeEvents 'next'
    @cells.erase cell
    cell.base.getParent('tr').destroy()
    cell.base.destroy()
    delete cell
  removeAll: ->
    (@cells.filter -> true).each ( (cell) ->
      @remove cell
    ).bind @
  getValue: ->
    map = @cells.map (cell) ->
      cell.getValue()
    map.splice(@cells.length-1,1)
    map
  setValue: (value) ->
    @removeAll()
    self = @
    value.each (item) ->
      self.add item
}
    


###
---

name: Iterable.ListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

requires: [GDotUI]
...
###
Iterable.ListItem = new Class {
  Extends:Core.Abstract
  Implements: [ Interfaces.Draggable
               Interfaces.Enabled ]
  options:{
    classes:{
      class: GDotUI.Theme.ListItem.class
      title: GDotUI.Theme.ListItem.title
      subtitle: GDotUI.Theme.ListItem.subTitle
      handle: GDotUI.Theme.ListItem.handle
    }
    icons:{
      remove: GDotUI.Theme.Icons.remove
      handle: GDotUI.Theme.Icons.handleVertical
    }
    offset: GDotUI.Theme.ListItem.offset
    title:''
    subtitle:''
    draggable: on
    dragreset: on
    ghost: on
    removeClasses: '.'+GDotUI.Theme.Icon.class
    invokeEvent: 'click'
    selectEvent: 'click'
    removeable: on
    sortable: off
    dropppables: ''
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass(@options.classes.class).setStyle  'position','relative'
    @remove = new Core.Icon {image: @options.icons.remove}
    @handles = new Core.Icon {image: @options.icons.handle}
    @handles.base.addClass  @options.classes.handle
    $$(@remove.base,@handles.base).setStyle 'position','absolute'
    @title = new Element('div').addClass(@options.classes.title).set 'text', @options.title
    @subtitle = new Element('div').addClass(@options.classes.subtitle).set 'text', @options.subtitle
    @base.adopt @title,@subtitle
    if @options.removeable
      @base.grab @remove
    if @options.sortable
      @base.grab @handle
    @base.addEvent @options.selectEvent, ( ->
      @fireEvent 'select', @
      ).bindWithEvent @
    @base.addEvent @options.invokeEvent, ( ->
      if @enabled and not @options.draggable and not @editing
        @fireEvent 'invoked', @
    ).bindWithEvent @
    @addEvent 'dropped', ( (el,drop,e) ->
      @fireEvent 'invoked', [@ ,e, drop]
    ).bindWithEvent @
    @base.addEvent 'dblclick', ( ->
      if @enabled
        if @editing
          @fireEvent 'edit', @
    ).bindWithEvent @
    @remove.addEvent 'invoked', ( ->
      @fireEvent 'delete', @
    ).bindWithEvent @
  toggleEdit: ->
    if @editing
      if @options.draggable
        @drag.attach()
      @remove.base.setStyle 'right', -@remove.base.getSize().x
      @handles.base.setStyle 'left', -@handles.base.getSize().x
      @base.setStyle 'padding-left' , @base.retrieve( 'padding-left:old')
      @base.setStyle 'padding-right', @base.retrieve( 'padding-right:old')
      @editing = off
    else
      if @options.draggable
        @drag.detach()
      @remove.base.setStyle 'right', @options.offset
      @handles.base.setStyle 'left', @options.offset
      @base.store 'padding-left:old', @base.getStyle('padding-left')
      @base.store 'padding-right:old', @base.getStyle('padding-left')
      @base.setStyle 'padding-left', Number(@base.getStyle('padding-left').slice(0,-2))+@handles.base.getSize().x
      @base.setStyle 'padding-right', Number(@base.getStyle('padding-right').slice(0,-2))+@remove.base.getSize().x
      @editing = on
  ready: ->
    if not @editing
      handSize = getCSS("/\\.#{@options.classes.handle}$/","width")
      remSize = getCSS("/\\.#{@options.classes.handle}$/","width")
      baseSize = getCSS("/\\.#{@options.classes.handle}$/","width")
      @remove.base.setStyles {
        "right":-remSize.x
        "top":(baseSize.y-remSize.y)/2
        }
      @handles.base.setStyles {
        "left":-handSize.x,
        "top":(baseSize.y-handSize.y)/2
        }
      @parent()
      if @options.draggable
        @drag.addEvent 'beforeStart',( ->
          #recalculate drops
          @fireEvent 'select', @
          ).bindWithEvent @
}


###
---

name: Forms.Field

description: Field Element for Forms.Fieldset.

license: MIT-style license.

requires: [Core.Abstract, Forms.Input, GDotUI]

provides: Forms.Field

...
###
Forms.Field = new Class {
  Extends:Core.Abstract
  options:{
    structure: GDotUI.Theme.Forms.Field.struct
    label: ''
  }
  initialize: (options) ->
    @parent options
    @
  create: ->
    h = new Hash @options.structure
    for key of h
      @base = new Element key
      @createS h.get( key ), @base
      break
    if @options.hidden
      @base.setStyle 'display', 'none'
  createS: (item,parent) ->
    if not parent?
      null
    else
      switch $type(item)
        when "object"
          for key of item
            data = new Hash(item).get key
            if key == 'input'
              @input = new Forms.Input @options  
              el = @input
            else if key == 'label'
              @label = new Element 'label', {'text':@options.label}
              el = @label
            else
              el = new Element key 
            parent.grab el
            @createS data , el
          
}


###
---

name: Forms.Fieldset

description: Fieldset for Forms.Form.

license: MIT-style license.

requires: [Core.Abstract, Forms.Field, GDotUI]

provides: Forms.Fieldset

...
###
Forms.Fieldset = new Class {
  Extends:Core.Abstract
  options:{
    name:''
    inputs:[]
  }
  initialize: (options) ->
    @parent options
  create: () ->
    delete @base
    @base = new Element 'fieldset'
    @legend = new Element 'legend', {text: @options.name}
    @base.grab @legend
    @options.inputs.each ( ( (item) ->
      @base.grab new Forms.Field(item)
    ).bindWithEvent this )
}


###
---

name: Forms.Form

description: Class for creating forms from javascript objects.

license: MIT-style license.

requires: [Core.Abstract, Forms.Fieldset, GDotUI]

provides: Forms.Form

...
###
Forms.Form = new Class {
  Extends:Core.Abstract
  Binds:['success', 'faliure']
  options:{
    data: {}
  }
  initialize: (options) ->
    @fieldsets = []
    @parent options
  create: ->
    delete @base
    @base = new Element 'form'
    if @options.data?
      @options.data.each( ( (fs) ->
        @addFieldset(new Forms.Fieldset(fs))
      ).bind @ )
    @extra=@options.extra;
    @useRequest=@options.useRequest;
    if @useRequest
      @request = new Request.JSON {url:@options.action, resetForm:false, method: @options.method }
      @request.addEvent 'success', @success
      @request.addEvent 'faliure', @faliure
    else
      @base.set 'action', @options.action
      @base.set 'method', @options.method
      
    @submit = new Element 'input', {type:'button', value:@options.submit}
    @base.grab @submit

    @validator = new Form.Validator @base, {serial:false}
    @validator.start();

    @submit.addEvent 'click', ( ->
      if @validator.validate()
        if @useRequest
          @send()
        else
          @fireEvent 'passed', @geatherdata()
      else
        @fireEvent 'failed', {message:'Validation failed'}
    ).bindWithEvent @
  addFieldset: (fieldset)->
    if @fieldsets.indexOf(fieldset) == -1
      @fieldsets.push fieldset
      @base.grab fieldset
  geatherdata: ->
    data = {}
    @base.getElements( 'select, input[type=text], input[type=password], textarea, input[type=radio]:checked, input[type=checkbox]:checked').each (item) ->
      data[item.get('name')] = if item.get('type')=="checkbox" then true else item.get('value')
    data
  send: ->
    @request.send {data: $extend(@geatherdata(), @extra)}
  success: (data) ->
    @fireEvent 'success', data
  faliure: ->
    @fireEvent 'failed', {message: 'Request error!'}
}


###
---

name: Pickers

description: Pickers for Data classes.

license: MIT-style license.

requires: [Core.Picker, Data.Color, Data.Number, Data.Text, Data.Date, Data.Time, Data.DateTime, GDotUI]

provides: [Pickers.Base, Pickers.Color, Pickers.Number, Pickers.Text, Pickers.Time, Pickers.Date, Pickers.DateTime ] 

...
###
Pickers.Base = new Class {
  Implements:Options
  Delegates:{
    picker:['attach'
            'detach'
            'attachAndShow']
    data: ['setValue'
          'getValue']
  }
  options:{
    type:''
  }
  initialize: (options) ->
    @setOptions options
    @picker = new Core.Picker()
    @data = new Data[@options.type]()
    @picker.setContent @data
    @
}
###
Pickers.Color = new Pickers.Base {type:'Color'}
Pickers.Number = new Pickers.Base {type:'Number'}
Pickers.Time = new Pickers.Base {type:'Time'}
Pickers.Text = new Pickers.Base {type:'Text'}
Pickers.Date = new Pickers.Base {type:'Date'}
Pickers.DateTime = new Pickers.Base {type:'DateTime'}
Pickers.Table = new Pickers.Base {type:'Table'}
Pickers.Unit = new Pickers.Base {type:'Unit'}
Pickers.Select = new Pickers.Base {type:'Select'}
Pickers.List = new Pickers.Base {type:'List'}
###
