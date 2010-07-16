###
---

name: GDotUI

description: 

license: MIT-style license.

requires: 

provides: GDotUI

...
###
Interfaces: {}
Core: {}
Data: {}
Iterable: {}
Pickers: {}

if !GDotUI?
  GDotUI: {}

GDotUI.Config:{
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

...
###
Interfaces.Mux: new Class {
  mux: ->
    (new Hash this).each( ( (value,key) ->
      if (key.test(/^_\$/) && $type(value)=="function")
        value.run null, this
    ).bind this )
}

###
---

name: Interfaces.Enabled

description: Provides enable and disable function to elements.

license: MIT-style license.

provides: Interfaces.Enabled

...
###
Interfaces.Enabled: new Class {
  enable: ->
    @enabled: on
    @base.removeClass 'disabled'
    @fireEvent 'enabled'
  disable: ->
    @enabled off
    @base.addClass 'disabled'
    @fireEvent 'disabled'
}

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

###
---

name: Interfaces.Restoreable

description: 

license: MIT-style license.

requires: 

provides: Interfaces.Restoreable

...
###
Interfaces.Restoreable: new Class {
  Impelments:[Options]
  options:{
    useCookie:true
    cookieID:null
  }
  _$Restoreable: ->
    @addEvent 'hide', ( ->
      if $chk @options.cookieID
        if @options.useCookie
          Cookie.write @options.cookieID+'.state', 'hidden', {duration:GDotUI.Config.cookieDuration}
        else
          window.localStorage.setItem @options.cookieID+'.state', 'hidden'
    ).bindWithEvent this
    @addEvent 'dropped', @savePosition.bindWithEvent this
  savePosition: ->
    if $chk @options.cookieID
      position: @base.getPosition();
      state: if @base.isVisible() then 'visible' else'hidden'
      if @options.useCookie
        Cookie.write @options.cookieID+'.x', position.x, {duration:GDotUI.Config.cookieDuration}
        Cookie.write @options.cookieID+'.y', position.y, {duration:GDotUI.Config.cookieDuration}
        Cookie.write @options.cookieID+'.state', state, {duration:GDotUI.Config.cookieDuration}
      else
        window.localStorage.setItem @options.cookieID+'.x', position.x
        window.localStorage.setItem @options.cookieID+'.y', position.y
        window.localStorage.setItem @options.cookieID+'.state', state
  loadPosition: ->
    if $chk @options.cookieID
      if @options.useCookie
        @base.setStyle 'top', Cookie.read(this.options.cookieID+'.y')+"px"
        @base.setStyle 'left', Cookie.read(this.options.cookieID+'.x')+"px"
        if Cookie.read(@options.cookieID+'.state') == "hidden"
          @hide();
      else
        @base.setStyle 'top', window.localStorage.getItem(this.options.cookieID+'.y')+"px"
        @base.setStyle 'left', window.localStorage.getItem(this.options.cookieID+'.x')+"px"
        if window.localStorage.getItem(this.options.cookieID+'.state') == "hidden" 
          @hide();
}

###
---

name: Interfaces.Controls

description: 

license: MIT-style license.

requires: 

provides: Interfaces.Controls

...
###
Interfaces.Controls: new Class {
  hide: ->
    @base.setStyle 'opacity', 0
  show: -> 
    @base.setStyle 'opacity', 1
}

###
---

name: Core.Abstract

description: 

license: MIT-style license.

requires: [Interfaces.Enabled, Interfaces.Controls]

provides: Core.Abstract

...
###
Core.Abstract: new Class {
  Implements:[Events
              Options
              Interfaces.Mux]
  initialize: (options) ->
    @setOptions options
    @base: new Element 'div'
    @create()
    fn: @ready.bindWithEvent this
    @base.store 'fn', fn
    @base.addEventListener 'DOMNodeInsertedIntoDocument', fn, no
    @mux()
    this
  create: ->
  ready: ->
    @base.removeEventListener 'DOMNodeInsertedIntoDocument', @base.retrieve('fn'), no
    @base.eliminate 'fn'
  toElement: ->
    @base
}


###
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, Interfaces.Enabled]

provides: Core.Icon

...
###
Core.Icon: new Class {
  Extends:Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  options:{
    image: null
    class: GDotUI.Theme.Icon.class
  }
  initialize: (options) ->
    @parent(options)
    @enabled: on
    this
  create: ->
    @base.addClass @options.class
    if @options.image?
      @base.setStyle 'background-image', 'url('+@options.image+')'
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [this, e]
      ).bindWithEvent this
}

###
---

name: Core.IconGroup

description: Icon group with 4 types of layout.

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.IconGroup

...
###
Core.IconGroup: new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Controls
  options:{
    mode:"horizontal" #horizontal / vertical / circular / grid
    spacing: {x:20
              y:20
            }
    startAngle:0 #degree
    radius:0 #degree
    degree:360 #degree
  }
  initialize: (options) ->
    @parent(options)
    @icons: []
    this
  create: ->
    @base.setStyle 'position', 'relative'
  addIcon: (icon) ->
    if @icons.indexOf icon == -1
      @base.grab icon
      @icons.push icon
      yes
    else no
  removeIcon: (icon) ->
    if @icons.indexOf icon != -1
      icon.base.dispose()
      @icons.push icon
      yes
    else no
  ready: ->
    x: 0
    y: 0
    @size: {x:0, y:0}
    spacing: @options.spacing
    switch @options.mode
      when 'grid'
        if @options.columns?
          columns=@options.columns;
          rows: @icons.length/columns;
        if @options.rows?
          rows=@options.rows;
          columns=Math.round @icons.length/rows
        icpos: @icons.map (item,i) ->
          if i%columns == 0
            x: 0
            y: if i==0 then y else y+item.base.getSize().y+spacing.y
          else
            x: if i==0 then x else x+item.base.getSize().x+spacing.x
          {x:x,y:y}
      when 'horizontal'
        icpos: @icons.map (item,i) ->
          x: if i==0 then x+x else x+item.base.getSize().x+spacing.x
          y: if i==0 then y else y+spacing.y
          {x:x,y:y}
      when 'vertical'
        icpos: @icons.map ((item,i) ->
          x: if i==0 then x else x+spacing.x
          y: if i==0 then y+y else y+item.base.getSize().y+spacing.y
          @size.x: item.base.getSize().x
          @size.y: y+item.base.getSize().y
          {x:x,y:y}
          ).bind this
      when 'circular'
        n: @icons.length
        radius: @options.radius
        startAngle: @options.startAngle
        ker: 2*@radius*Math.PI
        fok: @options.degree/n
        icpos: @icons.map (item,i) ->
          if i==0
            foks: startAngle*(Math.PI/180)
            x: -Math.round radius*Math.cos(foks)
            y: Math.round radius*Math.sin(foks)
          else
            x: -Math.round radius*Math.cos(((fok*i)+startAngle)*(Math.PI/180))
            y: Math.round radius*Math.sin(((fok*i)+startAngle)*(Math.PI/180))
          {x:x,y:y}
    @icons.each (item,i) ->
      item.base.setStyle 'top', icpos[i].y
      item.base.setStyle 'left', icpos[i].x
      item.base.setStyle 'position', 'absolute'
}

###
---

name: Core.Tip

description: Tip class.... (TODO Description)

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Tip

...
###
Core.Tip: new Class {
  Extends:Core.Abstract
  Binds:['enter'
         'leave']
  options:{
    text:""
    location: {x:"left"
               y:"bottom"}
    offset:5
  }
  initialize: (options) ->
    @parent options
    @create();
    this
  create:  ->
    @base.addClass GDotUI.Theme.tipClass
    @base.setStyle 'position','absolute'
    @base.setStyle 'z-index', GDotUI.Config.tipZindex
    @base.set 'html', this.options.text
  attach: (item) ->
    if not @attachedTo?
      @detach()
    item.base.addEvent 'mouseenter', @enter
    item.base.addEvent 'mouseleave', @leave
    @attachedTo: item
  detach: (item) ->
    item.base.removeEvent 'mouseenter', @enter
    item.base.removeEvent 'mouseleave', @leave
    @attachedTo: null
  enter: ->
    if @attachedTo.enabled
      @showTip()
  leave: ->
    if @attachedTo.enabled
      this.hideTip()
  showTip: ->
    p: @attachedTo.base.getPosition()
    s: @attachedTo.base.getSize();
    document.getElement('body').grab(@base)
    s1: @base.measure ->
          @getSize()
    switch @options.location.x
      when "left"
        @tip.setStyle 'left', p.x+(s.x+this.options.offset)
      when "right"
        @tip.setStyle 'left', p.x+(s.x+this.options.offset)
      when "center"
        @tip.setStyle 'left', p.x-s1.x/2+s.x/2
    switch @options.location.y
      when "top"
        @tip.setStyle 'top', p.y-(s.y+this.options.offset)
      when "bottom"
        @tip.setStyle 'top', p.y+(s.y+this.options.offset)
      when "center"
        @tip.setStyle 'top', p.y-s1.y/2+s.y/2
  hideTip: ->
    @base.dispose()
}

###
---

name: Core.Slider

description: 

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls]

provides: [Core.Slider, ResetSlider]

...
###
ResetSlider: new Class {
	Extends:Slider
	initialize: (element, knob, options) ->
		@parent(element, knob, options)
	setRange: (range) ->
		@min = $chk(range[0]) ? range[0] : 0;
		@max = $chk(range[1]) ? range[1] : @.steps;
		@range = @max - @min;
		@steps = @options.steps || @full;
		@stepSize = Math.abs(@range) / @steps;
		@stepWidth = @stepSize * @full / Math.abs(@range) ;
}
Class.Mutators.Delegates: (delegations) ->
	self = this;
	(new Hash delegations).each (delegates, target) ->
		($splat delegates).each (delegate) ->
			self.prototype[delegate]: ->
				ret: @[target][delegate].apply @[target], arguments
				if ret == @[target] then this else ret

Core.Slider: new Class {
	Extends:Core.Abstract
	Implements:[Interfaces.Controls]
	Delegates:{ slider:[
		'set'
		'setRange'
	]}
	options:{
		scrollBase: null
		reset: off
		mode: 'vertical'
		class: GDotUI.Theme.Slider.barClass
		knob: GDotUI.Theme.Slider.knobClass
	}
	initialize: (options) ->
		@parent(options)
		this
	create: ->
		@base.addClass @options.class
		@knob: (new Element 'div').addClass @options.knob
		if @options.mode=="vertical"
			@base.setStyles {
				'width':GDotUI.Theme.Slider.width
				'height':GDotUI.Theme.Slider.length
			} 
			@knob.setStyles {
				'width':GDotUI.Theme.Slider.width
				'height':GDotUI.Theme.Slider.width*2
			}
		else
			@base.setStyles {
				'width':GDotUI.Theme.Slider.length
				'height':GDotUI.Theme.Slider.width
			}
			@knob.setStyles {
				'width':GDotUI.Theme.Slider.width*2
				'height':GDotUI.Theme.Slider.width
			}
		@scrollBase: @options.scrollBase
		@base.grab @knob
	ready: ->
		if @options.reset
			@slider: new ResetSlider @base, @knob, {mode:@options.mode
																							steps:@options.steps
																							range:@options.range}
			@slider.set 0
		else
			@slider=new Slider @base, @knob, {mode:@options.mode
																				steps:100}
		@slider.addEvent 'complete', ((step) ->
			@fireEvent 'complete', step+''
		).bindWithEvent this
		@slider.addEvent 'change', ((step)->
			if typeof(step) == 'object'
				step=0;
			@fireEvent 'change', step+''
			if @scrollBase != null
					@scrollBase.scrollTop: (@scrollBase.scrollHeight-@scrollBase.getSize().y)/100*step
		).bindWithEvent this
		@parent()
}


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
		console.log(@icons.size.y)
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
			if @contentElement?
				if @contentElement.toggleEdit?
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

###
---

name: Core.Button

description: 

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Enabled, Interfaces.Controls]

provides: Core.Button

...
###
Core.Button: new Class {
  Extends:Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  options:{
    image: ''
    text: ''
    class: GDotUI.Theme.Button.class
  }
  initialize: (options) ->
    @parent(options)
    @enabled: on
    this
  create: ->
    delete @base
    @base: new Element 'button'
    @base.addClass(this.options['class']).set 'text', @options.text
    @icon: new Core.Icon {image:@options.image}
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [this, e]
      ).bindWithEvent this
  ready: ->
      @base.grab @icon
      @icon.base.setStyle 'float', 'left'
      @parent();
}

###
---

name: Core.Picker

description: 

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Picker

...
###
Element.Events.outerClick: {
    base: 'click'
    condition: (event) ->
      event.stopPropagation();
      off
    onAdd: (fn) ->
      window.addEvent 'click', fn
    onRemove: (fn) ->
      window.removeEvent 'click', fn
};
Core.Picker: new Class {
  Extends:Core.Abstract
  Binds: ['show'
          'hide']
  options:{
    class:GDotUI.Theme.Picker.class
    offset:GDotUI.Theme.Picker.offset
  }
  initialize: (options) ->
    @parent(options)
    this
  create: ->
    @base.addClass @options.class
    @base.setStyle 'position', 'absolute'
  ready: ->
    if not @base.hasChild @contentElement
       @base.grab @contentElement
    winsize: window.getSize()
    asize: @attachedTo.getSize()
    position: @attachedTo.getPosition()
    size: @base.getSize()
    offset: @options.offset;
    x: ''
    y: ''
    if (position.x-size.x) < 0
      x: 'right'
      xpos: position.x+asize.x+offset
    if (position.x+size.x+asize.x) > winsize.x
      x: 'left'
      xpos: position.x-size.x-offset
    if not ((position.x+size.x+asize.x)>winsize.x) and not ((position.x-size.x) < 0) 
      x: 'center'
      xpos: (position.x+asize.x/2)-(size.x/2)
    if position.y > (winsize.x/2)
      y: 'up'
      ypos: position.y-size.y-offset
    else
      y: 'down'
      if x=='center'
        ypos: position.y+asize.y+offset
      else
        ypos: position.y
    @base.setStyles {
      'left':xpos
      'top':ypos
    }
  attach: (input) ->
    input.addEvent 'click', this.show #bind???
    @contentElement.addEvent 'change', ((value) ->
      @attachedTo.set 'value', value
      @attachedTo.fireEvent 'change', value
    ).bindWithEvent this
    @attachedTo=input
  show: (e) ->
    document.getElement('body').grab @base
    @attachedTo.addClass 'picking'
    e.stop()
    @base.addEvent 'outerClick', this.hide #bind here too???
  hide: ->
    if @base.isVisible()
      @attachedTo.removeClass 'picking'
      @base.dispose()
  setContent: (element) ->
    @contentElement element
}

###
---

name: Core.Slot

description: Generic icon element.

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Slot

...
###
Core.Slot: new Class {
  Extends:Core.Abstract
  Binds:['check'
         'complete']
  Delegates:{
    'list':['addItem'
            'removeAll'
            'select']
  }
  options:{
    class:GDotUI.Theme.Slot.class
  }
  initilaize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @overlay: new Element 'div', {'text':' '}
    @overlay.addClass 'over'
    @list: new Iterable.List()
    @list.addEvent 'select', ((item) ->
      @update()
      @fireEvent 'change', item
    ).bindWithEvent this
    @base.adopt @list.base, @overlay
  check: (el,e) ->
    @dragging: on
    lastDistance: 1000
    lastOne: null
    @list.items.each( ( (item,i) ->
      distance: -item.base.getPosition(@base).y+@base.getSize().y/2
      if distance < lastDistance and distance > 0 and distance < @base.getSize().y/2
        @list.select item
    ).bind this )
  ready: -> 
    @parent()
    @base.setStyle 'overflow', 'hidden'
    @base.setStyle 'position', 'relative'
    @list.base.setStyle 'position', 'absolute'
    @list.base.setStyle 'top', '0'
    @base.setStyle 'width', @list.base.getSize().x
    @overlay.setStyle 'width', @base.getSize().x
    @overlay.addEvent 'mousewheel',( (e) ->
      e.stop();
      if @list.selected?
        index: @list.items.indexOf @list.selected
      else
        if e.wheel==1
          index: 0
        else
          index: 1
      if index+e.wheel >= 0 and index+e.wheel < @list.items.length 
        @list.select @list.items[index+e.wheel]
      if index+e.wheel < 0
        @list.select @list.items[@list.items.length-1]
      if index+e.wheel > @list.items.length-1
        @list.select @list.items[0]
    ).bindWithEvent this
    @drag: new Drag @list.base, {modifiers:{x:'',y:'top'},handle:@overlay}
    @drag.addEvent 'drag', @check
    @drag.addEvent 'beforeStart',( ->
      @list.base.setStyle '-webkit-transition-duration', '0s'
    ).bindWithEvent this
    @drag.addEvent 'complete', ( ->
      @dragging: off
      @update()
    ).bindWithEvent this
  update: ->
    if not @dragging
      @list.base.setStyle '-webkit-transition-duration', '0.3s'
      if @list.selected?
        @list.base.setStyle 'top',-@list.selected.base.getPosition(@list.base).y+@base.getSize().y/2-@list.selected.base.getSize().y/2
}

###
---

name: Data.Abstract

description: 

license: MIT-style license.

requires: 

provides: Data.Abstract

...
###
Data.Abstract: new Class {
  Implements:[Events
              Options]
  options:{}
  initialize: (options) ->
    @setOptions options
    @base: new Element 'div'
    fn: @ready.bindWithEvent this
    @base.store 'fn', fn
    @base.addEventListener 'DOMNodeInsertedIntoDocument', fn, no
    @create()
    this
  create: ->
  ready: ->
    @base.removeEventListener 'DOMNodeInsertedIntoDocument', @base.retrieve('fn'), no
    @base.eliminate 'fn'
  toElement: ->
    @base
  setValue: ->
  getValue: ->
}








###
---

name: Data.Date

description: 

license: MIT-style license.

requires: [Data.Abstract, Core.Slot]

provides: Data.Date

...
###
Data.Date: new Class {
  Extends:Data.Abstract
  options:{
    class:GDotUI.Theme.Date.Slot.class
    format:GDotUI.Theme.Date.format
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @days: new Core.Slot()
    @month: new Core.Slot()
    @years: new Core.Slot()
    @years.addEvent 'change', ( (item) ->
      @date.setYear item.value
      @setValue()
    ).bindWithEvent this
    @month.addEvent 'change', ( (item) ->
      @date.setMonth item.value
      @setValue();
    ).bindWithEvent this
    @days.addEvent 'change', ( (item) ->
      @date.setDate item.value
      @setValue()
    ).bindWithEvent this
    i: 0
    while i < 30
      item: new Iterable.ListItem {title:i+1}
      item.value: i+1;
      @days.addItem item
      i++
    i: 0
    while i < 12
      item: new Iterable.ListItem {title:i+1}
      item.value: i
      @month.addItem item
      i++
    i: 1950
    while i < 2012
      item: new Iterable.ListItem {title:i}
      item.value: i;
      @years.addItem item
      i++
    this
  ready: -> 
    @base.adopt @years, @month, @days
    @setValue new Date()
    @base.setStyle 'height', @days.base.getSize().y
    $$(@days.base,@month.base,@years.base).setStyles {'float':'left'}
    @parent()
  setValue: (date) ->
    if date?
      @date: date
    @update()
    @fireEvent 'change', @date.format(@options.format)
  update: ->
    cdays: @date.get 'lastdayofmonth'
    listlength: @days.list.items.length
    if cdays>listlength
      i: listlength+1
      while i<=cdays
        item=new Iterable.ListItem {title:i}
        item.value: i
        @days.addItem item
        i++
    else if cdays<listlength
      i: listlength
      while i>cdays
        @days.list.removeItem @days.list.items[i-1]
        i--
    @days.select @days.list.items[@date.getDate()-1]
    @month.select @month.list.items[@date.getMonth()]
    @years.select @years.list.getItemFromTitle(@date.getFullYear())
}



###
---

name: Iterable.ListItem

description: 

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

...
###
Iterable.ListItem: new Class {
  Extends:Core.Abstract
  options:{
    class:GDotUI.Theme.ListItem.class
    title:''
    subtitle:''
  }
  initialize: (options) ->
    @parent options
    @enabled: on
  create: ->
    @base.addClass(@options.class).setStyle  'position','relative'
    @remove: new Core.Icon {image:GDotUI.Theme.Icons.remove}
    @handle: new Core.Icon {image:GDotUI.Theme.Icons.handleVertical}
    @handle.base.addClass 'list-handle'
    $$(@remove.base,@handle.base).setStyle 'position','absolute'
    @title: new Element('div').addClass(GDotUI.Theme.ListItem.title).set 'text', @options.title
    @subtitle: new Element('div').addClass(GDotUI.Theme.ListItem.subTitle).set 'text', @options.subtitle
    @base.adopt @title,@subtitle, @remove, @handle
    #Invoked
    @base.addEvent 'click', ( ->
      if @enabled
        @fireEvent 'invoked', this
     ).bindWithEvent this
     @base.addEvent 'dblclick', ( ->
       if @enabled
         if @editing
           @fireEvent 'edit', this
     ).bindWithEvent this
  toggleEdit: ->
    if @editing
      @remove.base.setStyle 'right', -@remove.base.getSize().x
      @handle.base.setStyle 'left', -@handle.base.getSize().x
      @base.setStyle 'padding-left', @base.retrieve('padding-left:old')
      @base.setStyle 'padding-right', @base.retrieve('padding-right:old')
      @editing: off
    else
      @remove.base.setStyle 'right',GDotUI.Theme.ListItem.iconOffset
      @handle.base.setStyle 'left',GDotUI.Theme.ListItem.iconOffset
      @base.store 'padding-left:old', @base.getStyle('padding-left')
      @base.store 'padding-right:old', @base.getStyle('padding-left')
      @base.setStyle 'padding-left', Number(@base.getStyle('padding-left').slice(0,-2))+@handle.base.getSize().x
      @base.setStyle 'padding-right', Number(@base.getStyle('padding-right').slice(0,-2))+@remove.base.getSize().x
      @editing: on
  ready: ->
    if not @editing
      handSize: @handle.base.getSize()
      remSize: @remove.base.getSize()
      baseSize: @base.getSize()
      @remove.base.setStyles {
        "right":-remSize.x
        "top":(baseSize.y-remSize.y)/2
        }
      @handle.base.setStyles {
        "left":-handSize.x,
        "top":(baseSize.y-handSize.y)/2
        }
      @parent()
}

###
---

name: Iterable.List

description: 

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.List

...
###
Iterable.List: new Class {
  Extends:Core.Abstract
  options:{
    class: GDotUI.Theme.List.class
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @sortable: new Sortables null, {handle:'.list-handle'}
    #TODO Sortable Events
    @editing: off
    @items: []
  removeItem: (li) ->
    li.removeEvents 'invoked', 'edit', 'delete'
    li.base.destroy()
    @items.erase li
    delete li
  removeAll: ->
    @selected: null
    @items.each( ( ->
      @removeItem item
      ).bind this)
    delete @items
    @items: []
  toggleEdit: ->
    bases: @items.map (item) ->
      return item.base
    if @editing
      @sortable.removeItems bases
      @items.each (item) ->
        item.toggleEdit()
      @editing: off
    else
      @sortable.addItems bases
      @items.each (item) ->
        item.toggleEdit()
      @editing: on
  getItemFromTitle: (title) ->
    filtered: @items.filter (item) ->
      if item.title.get('text') == String(title)
        yes
      else no
    filtered[0]
  select: (item) ->
    if @selected != item
      if @selected?
        @selected.base.removeClass 'selected'
      @selected: item
      @selected.base.addClass 'selected'
      @fireEvent 'select', item
  addItem: (li) -> 
    @items.push li
    @base.grab li
    li.addEvent 'invoked', ( (item) ->
      @select item
      @fireEvent 'invoked', [item]
      ).bindWithEvent this
    li.addEvent 'edit', ( -> 
      @fireEvent 'edit', arguments
      ).bindWithEvent this
    li.addEvent 'delete', ( ->
      @fireEvent 'delete', arguments
      ).bindWithEvent this
}
###
toTheTop:function(item){
  //console.log(item);
  //@base.setStyle('top',@base.getPosition().y-item.base.getSize().y);
  @items.erase(item);
  @items.unshift(item);
  
},
update:function(){
  @items.each(function(item,i){
    item.base.dispose();
    @base.grab(item.base,'top');
  }.bind(this))
},
###



###
---

name: Core.Overlay

description: Abstract base class for Elements.

license: MIT-style license.

requires: Core.Abstract

provides: Core.Overlay

...
###
Core.Overlay: new Class {
  Extends:Core.Abstract
  options:{
    class: GDotUI.Theme.Overlay.class
  }
  initialize: (options) ->
    @parent(options)
    this
  create: ->
    @base.setStyles {
      "position":"fixed"
      "top":0
      "left":0
      "right":0
      "bottom":0
      "opacity":0
      }
    @base.addClass @options.class
    (document.getElement 'body' ).grab @.base
    @base.addEventListener 'webkitTransitionEnd', ((e) ->
      if e.propertyName=="opacity" and @base.getStyle('opacity') == 0
        @base.setStyle 'visiblity', 'hidden'
      ).bindWithEvent this
  hide: ->
    @base.setStyle 'opacity', 0
  show: ->
    @base.setStyles {
      'visiblity': 'visible'
      'opacity': 1
    }
}