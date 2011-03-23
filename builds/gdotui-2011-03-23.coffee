###
---

name: Element.Extras

description: Extra functions and monkeypatches for moootols Element.

license: MIT-style license.

provides: Element.Extras

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
( ->
  oldPrototypeStart = Drag::start
  Drag.prototype.start = ->
    window.fireEvent 'outer'
    oldPrototypeStart.run arguments, @
)()
(->
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
  Element.implement {
    oldGrab: Element::grab
    oldInject: Element::inject
    oldAdopt: Element::adopt
    
    removeTransition: ->
      @store 'transition', @getStyle( '-webkit-transition-duration' )
      @setStyle '-webkit-transition-duration', '0'
      
    addTransition: ->
      @setStyle '-webkit-transition-duration', @retrieve( 'transition' )
      @eliminate 'transition'
      
    inTheDom: ->
      if @parentNode
        if @parentNode.tagName.toLowerCase() is "html"
          true
        else
          $(@parentNode).inTheDom
      else
        false
        
    grab: (el, where) ->
      @oldGrab.attempt arguments, @
      e = document.id(el)
      if e.fireEvent?
        e.fireEvent 'addedToDom'
      @
      
    inject: (el, where) ->
      @oldInject.attempt arguments, @
      @fireEvent 'addedToDom'
      @
      
    adopt: ->
      @oldAdopt.attempt arguments, @
      elements = Array.flatten(arguments)
      elements.each (el) ->
        e = document.id(el)
        if e.fireEvent?
          document.id(el).fireEvent 'addedToDom'
      @
  }
)()


###
---
name: Class.Extras
description: Extra suff for Classes.

license: MIT-style

authors:
  - Kevin Valdek
  - Perrin Westrich
  - Maksim Horbachevsky
provides:
  - Class.Delegates
  - Class.Attributes
...
###
Class.Mutators.Delegates = (delegations) ->
	self = @
	new Hash(delegations).each (delegates, target) ->
		$splat(delegates).each (delegate) ->
			self.prototype[delegate] = ->
				ret = @[target][delegate].apply @[target], arguments
				if ret is @[target] then @ else ret

Class.Mutators.Attributes = (attributes) ->
    $setter = attributes.$setter
    $getter = attributes.$getter
    
    if @::$attributes
      attributes = Object.merge @::$attributes, attributes

    delete attributes.$setter
    delete attributes.$getter

    @implement new Events

    @implement {
      $attributes: attributes
      get: (name) ->
        attr = @$attributes[name]
        if attr 
          if attr.valueFn && !attr.initialized
            attr.initialized = true
            attr.value = attr.valueFn.call @
          if attr.getter
            return attr.getter.call @, attr.value
          else
            return attr.value
        else
          return if $getter then $getter.call(@, name) else undefined

      set: (name, value) ->
          attr = @$attributes[name]
          if attr
            if !attr.readOnly
              oldVal = attr.value
              if !attr.validator or attr.validator.call(@, value)
                if attr.setter
                  newVal = attr.setter.attempt [value, oldVal], @
                else
                  newVal = value             
                attr.value = newVal
                @[name] = newVal
                #if attr.update
                @update()
                if oldVal isnt newVal
                  @fireEvent name + 'Change', { newVal: newVal, oldVal: oldVal }
                newVal
          else if $setter
            $setter.call @, name, value

      setAttributes: (attributes) ->
        attributes = Object.merge {}, attributes
        Object.each @$attributes, (value,name) ->
          if attributes[name]?
            @set name, attributes[name]
          else if value.value?
            @set name, value.value
        , @

      getAttributes: () ->
        attributes = {}
        $each(@$attributes, (value, name) ->
          attributes[name] = @get(name)
        , @)
        attributes

      addAttributes: (attributes) ->
        $each(attributes, (value, name) ->
            @addAttribute(name, value)
        , @)

      addAttribute: (name, value) ->
        @$attributes[name] = value
        @
  }


###
---

name: GDotUI

description: G.UI

license: MIT-style license.

provides: GDotUI

requires: [Class.Delegates, Element.Extras]

...
###
Interfaces = {}
Core = {}
Data = {}
Iterable = {}
Pickers = {}
Forms = {}
Dialog = {}

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
    new Hash(@).each (value,key) ->
      if key.test(/^_\$/) && typeOf(value)=="function"
        value.attempt null, @
    , @
}


###
---

name: Core.Abstract

description: Abstract base class for Core U.I. elements.

license: MIT-style license.

requires: 
  - Class.Extras
  - Element.Extras
  - GDotUI
  - Interfaces.Mux

provides: Core.Abstract

...
###

#INK save nodedata to html file in a comment.
# move this somewhere else
getCSS = (selector, property) ->
  #selector = "/\\.#{@get('class')}$/"
  ret = null
  checkStyleSheet = (stylesheet) ->
    try
      if stylesheet.cssRules?
        $A(stylesheet.cssRules).each (rule) ->
          if rule.styleSheet?
            checkStyleSheet(rule.styleSheet)
          if rule.selectorText?
            if rule.selectorText.test(eval(selector))
              ret = rule.style.getPropertyValue(property)
    catch error
      console.log error
  $A(document.styleSheets).each (stylesheet) ->
    checkStyleSheet(stylesheet)
  ret

Core.Abstract = new Class {
  Implements:[Events
              Interfaces.Mux]
  Attributes: {
    class: {
      setter: (value, old) ->
        value = String.from value
        @base.removeClass old
        @base.addClass value
        value
    }
  }
  initialize: (options) ->
    @base = new Element 'div'
    @base.addEvent 'addedToDom', @ready.bind @
    @mux()
    @create()
    @setAttributes options
    @
  create: ->
  update: ->
  ready: ->
    @base.removeEvents 'addedToDom'
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
    if @base.getStyle('opacity') is 0
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
  supress: ->
    if @children?
      @children.each (item) ->
        if item.disable?
          item.supress()
    @base.addClass 'supressed'
    @enabled = off
  unsupress: ->
    if @children?
      @children.each (item) ->
        if item.enable?
          item.unsupress()
    @base.removeClass 'supressed'
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


###
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Controls 
  - Interfaces.Enabled

provides: Core.Icon

...
###
Core.Icon = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  Attributes: {
    image: {
      setter: (value) ->
        @base.setStyle 'background-image', 'url(' + value + ')'
        value
    }
    class: {
      value: GDotUI.Theme.Icon.class
    }
  }
  create: ->
    @base.addEvent 'click', ( ->
      if @enabled
        @fireEvent 'invoked', @
    ).bind @
}


###
---

name: Interfaces.Children

description: 

license: MIT-style license.

requires: [GDotUI]

provides: Interfaces.Children

...
###
Interfaces.Children = new Class {
  _$Children: ->
    @children = []
  hasChild: (child) ->
    if @children.indexOf child is -1 then no else yes
  adoptChildren: ->
    children = Array.from(arguments)
    @children.append children
    @base.adopt arguments
  addChild: (el) ->
    @children.push el
    @base.grab el
  removeChild: (el) ->
    if @children.contains(el)
      @children.erease el
      el.dispose()
}


###
---

name: Core.IconGroup

description: Icon group with 5 types of layout.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Children
  - Interfaces.Enabled

provides: Core.IconGroup

todo: Circular center position and size
...
###
Core.IconGroup = new Class {
  Extends: Core.Abstract
  Implements: [Interfaces.Controls, Interfaces.Enabled, Interfaces.Children]
  Binds: ['delegate']
  Attributes: {
    mode: {
      value: "horizontal"
      validator: (value) ->
        if ['horizontal','vertical','circular','grid','linear'].indexOf(value) > -1 then true else false
    }
    spacing: {
      value: {x: 0,y: 0}
      validator: (value) ->
        if typeOf(value) is 'object'
          if value.x? and value.y? then yes else no
        else no
    }
    startAngle: {
      value: 0
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          (a >= 0 and a <= 360)
        else no
    }
    radius: {
      value: 0
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        (a = Number.from(value))?
    }
    degree: {
      value: 360
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          a >= 0 and a <= 360
        else no
    }
    rows: {
      value: 1
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          a > 0
        else no
    }
    columns: {
      value: 1
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          a > 0
        else no
    }
    class: {
      value: GDotUI.Theme.IconGroup.class
    }
  }
  create: ->
    @base.setStyle 'position', 'relative'
  delegate: ->
    @fireEvent 'invoked', arguments
  addIcon: (icon) ->
    if not @hasChild icon
      icon.addEvent 'invoked', @delegate
      @addChild icon
      @update()
  removeIcon: (icon) ->
    if @hasChild icon
      icon.removeEvent 'invoked', @delegate
      @removeChild icon
      @update()
  ready: ->
    @update()
  update: ->
    if @children.length > 0 and @mode? 
      x = 0
      y = 0
      @size = {x:0, y:0}
      spacing = @spacing
      switch @mode
        when 'grid'
          if @rows? and @columns?
            if Number.from(@rows) < Number.from(@columns)
              rows = null
              columns = @columns
            else
              columns = null
              rows = @rows
          icpos = @children.map ((item,i) ->
            if rows?
              if i % rows == 0
                y = 0
                x = if i==0 then x else x+item.base.getSize().x+spacing.x
              else
                y = if i==0 then y else y+item.base.getSize().y+spacing.y
            if columns?
              if i % columns == 0
                x = 0
                y = if i==0 then y else y+item.base.getSize().y+spacing.y
              else
                x = if i==0 then x else x+item.base.getSize().x+spacing.x
            @size.x = x+item.base.getSize().x
            @size.y = y+item.base.getSize().y
            {x:x, y:y}
            ).bind @
        when 'linear'
          icpos = @children.map ((item,i) ->
            x = if i==0 then x+x else x+spacing.x+item.base.getSize().x
            y = if i==0 then y+y else y+spacing.y+item.base.getSize().y
            @size.x = x+item.base.getSize().x
            @size.y = y+item.base.getSize().y
            {x:x, y:y}
            ).bind @
        when 'horizontal'
          icpos = @children.map ((item,i) ->
            x = if i==0 then x+x else x+item.base.getSize().x+spacing.x
            y = if i==0 then y else y
            @size.x = x+item.base.getSize().x
            @size.y = item.base.getSize().y
            {x:x, y:y}
            ).bind @
        when 'vertical'
          icpos = @children.map ((item,i) ->
            x = if i==0 then x else x
            y = if i==0 then y+y else y+item.base.getSize().y+spacing.y
            @size.x = item.base.getSize().x
            @size.y = y+item.base.getSize().y
            {x:x,y:y}
            ).bind @
        when 'circular'
          n = @children.length
          radius = @radius
          startAngle = @startAngle
          ker = 2*@radius*Math.PI
          fok = @degree/n
          icpos = @children.map (item,i) ->
            if i==0
              foks = startAngle * (Math.PI/180)
              x = Math.round(radius * Math.sin(foks))+radius/2+item.base.getSize().x
              y = -Math.round(radius * Math.cos(foks))+radius/2+item.base.getSize().y
            else
              x = Math.round(radius * Math.sin(((fok * i) + startAngle) * (Math.PI/180)))+radius/2+item.base.getSize().x
              y = -Math.round(radius * Math.cos(((fok * i) + startAngle) * (Math.PI/180)))+radius/2+item.base.getSize().y
            {x:x, y:y}
      @base.setStyles {
        width: @size.x
        height: @size.y
      }
      @children.each (item,i) ->
        item.base.setStyle 'top', icpos[i].y
        item.base.setStyle 'left', icpos[i].x
        item.base.setStyle 'position', 'absolute'
}


###
---

name: Core.Tip

description: Tip class

license: MIT-style license.

requires: 
  - Core.Abstract
  - GDotUI

provides: Core.Tip

...
###
Core.Tip = new Class {
  Extends:Core.Abstract
  Implements: Interfaces.Enabled
  Binds:[
    'enter'
    'leave'
  ]
  Attributes: {
    class: {
      value: GDotUI.Theme.Tip.class
    }
    label: {
      value: ''
      setter: (value) ->
        @base.set 'html', value
    }
    zindex: {
      value: 1
      setter: (value) ->
        @base.setStyle 'z-index', value
    }
    delay: {
      value: 0
    }
    location: {
      value: {x:'center',y:'center'}
    }
    offset: {
      value: 0
    }
  }
  create: ->
    @base.setStyle 'position', 'absolute'
  attach: (item) ->
    if @attachedTo?
      @detach()
    @attachedTo = document.id(item)
    @attachedTo.addEvent 'mouseenter', @enter
    @attachedTo.addEvent 'mouseleave', @leave
  detach: ->
    @attachedTo.removeEvent 'mouseenter', @enter
    @attachedTo.removeEvent 'mouseleave', @leave
    @attachedTo = null
  enter: ->
    if @enabled
      @over = true
      @id = ( ->
        if @over
          @show()
      ).bind(@).delay @delay
  leave: ->
    if @enabled
      if @id?
        clearTimeout(@id)
        @id = null
      @over = false
      @hide()
  ready: ->
    # monkeypatch this
    size = @base.getSize()
    offset = {x:0,y:0}
    switch @location.x
      when 'center'
        if @location.y isnt 'center'
          offset.x = -size.x/2
      when 'left'
        offset.x = -(@offset+size.x)
      when 'right'
        offset.x = @offset
    switch @location.y
      when 'center'
        if @location.x isnt 'center'
          offset.y = -size.y/2
      when 'top'
        offset.y = -(@offset+size.y)
      when 'bottom'
        offset.y = @offset
    @base.position {
      relativeTo: @attachedTo
      position: @location
      offset: offset
    }
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

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled

provides: Core.Slider

todo: fix progress width and height mode change, implement range at some point
...
###
Core.Slider = new Class {
  Extends:Core.Abstract
  Implements:[
    Interfaces.Controls
    Interfaces.Enabled
  ]
  Attributes: {
    class: {
      value: GDotUI.Theme.Slider.classes.base
    }
    mode: {
      value: 'horizontal'
      setter: (value, old) ->
        @base.removeClass old
        @base.addClass value
        switch value
          when 'horizontal'
            @minSize = Number.from getCSS("/\\.#{@get('class')}.horizontal$/",'min-width')
            @modifier = 'width'
            @drag.options.modifiers = {x: 'width',y:''}
            @drag.options.invert = false
            if not @size?
              size = Number.from getCSS("/\\.#{@get('class')}.horizontal$/",'width')
            @set 'size', size
            @base.setStyle 'height', Number.from getCSS("/\\.#{@get('class')}.horizontal$/",'height')
            @progress.setStyles {
              top: 0
              right: 'auto'
            }
          when 'vertical'
            @minSize = Number.from getCSS("/\\.#{@get('class')}.vertical$/",'min-hieght')
            @modifier = 'height'
            @drag.options.modifiers = {x: '',y: 'height'}
            @drag.options.invert = true
            if not @size?
              size = Number.from getCSS("/\\.#{@class}.vertical$/",'height')
            @set 'size', size
            @base.setStyle 'width', Number.from getCSS("/\\.#{@class}.vertical$/",'width')
            @progress.setStyles {
              right: 0
              top: 'auto'
            }
        value
    }
    bar: {
      value: GDotUI.Theme.Slider.classes.bar
      setter: (value, old) ->
        @progress.removeClass old
        @progress.addClass value
        value
    }
    reset: {
      value: off
    }
    steps: {
      value: 100
    }
    range: {
      value: [0,0]
    }
    size: {
      setter: (value, old) ->
        if !value?
          value = old
        if @minSize > value
          value = @minSize
        @base.setStyle @modifier, value
        @progress.setStyle @modifier, if @reset then value/2 else @value/@steps*value
        value
    }
    value: {
      value: 0
      setter: (value) ->
        if !@reset
          percent = Math.round((value/@steps)*100)
          if value < 0
            @progress.setStyle @modifier, 0
            value = 0
          if @value > @steps
            @progress.setStyle @modifier, @size
            value = @steps
          if not(value < 0) and not(value > @steps)
            @progress.setStyle @modifier, (percent/100)*@size
        value
    }
  }
  create: ->
    @base.setStyle 'position', 'relative'
    @progress = new Element "div"
    @progress.setStyles {
      position: 'absolute'
      bottom: 0
      left: 0
    }      
    @base.adopt @progress
    
    @drag = new Drag @progress, {handle:@base}
    @drag.addEvent 'beforeStart', ( (el,e) ->
      @lastpos = Math.round((Number.from(el.getStyle(@modifier))/@size)*@steps)
      if not @enabled
        @disabledTop = el.getStyle @modifier
    ).bind @
    @drag.addEvent 'complete', ( (el,e) ->
      if @reset
        if @enabled
          el.setStyle @modifier, @size/2+"px"
      @fireEvent 'complete'
    ).bind @
    @drag.addEvent 'drag', ( (el,e) ->
      if @enabled
        pos = Number.from el.getStyle(@modifier)
        offset = Math.round((pos/@size)*@steps)-@lastpos
        @lastpos = Math.round((Number.from(el.getStyle(@modifier))/@size)*@steps)
        if pos > @size
          el.setStyle @modifier, @size
          pos = @size
        else
          if @reset
            @value += offset
        if not @reset
          @value = Math.round((pos/@size)*@steps)
        @fireEvent 'step', @value
        @update()
      else
        el.setStyle @modifier, @disabledTop
    ).bind @
    @base.addEvent 'mousewheel', ( (e) ->
      e.stop()
      if @enabled
        @set 'value', @value+Number.from(e.wheel)
        @fireEvent 'step', @value
    ).bind @

}


###
---

name: Interfaces.Size

description: Size minsize from css....

license: MIT-style license.

provides: Interfaces.Size

requires: [GDotUI]
...
###
Interfaces.Size = new Class {
  _$Size: ->
    @size = Number.from getCSS("/\\.#{@get('class')}$/",'width')
    @minSize = Number.from(getCSS("/\\.#{@get('class')}$/",'min-width')) or 0
    @addAttribute 'minSize', {
      value: null
      setter: (value,old) ->
        @base.setStyle 'min-width', value
        value      
    }
    @addAttribute 'size', {
      value: null
      setter: (value, old) ->
        size = if value < @minSize then @minSize else value
        @base.setStyle 'width', size
        size
    }
  
}


###
---

name: Core.Button

description: Basic button element.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled
  - Interfaces.Size

provides: Core.Button

...
###
Core.Button = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
    Interfaces.Size
  ]
  Attributes: {
    label: {
      value: GDotUI.Theme.Button.label
      setter: (value) ->
        @base.set 'text', value
        value
    }
    class: {
      value: GDotUI.Theme.Button.class
    }
  }
  create: ->
    @base.addEvent 'click', ( ->
      if @enabled
        @fireEvent 'invoked', @
    ).bind @
}


###
---

name: Core.Picker

description: Data picker class.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Children
  - Interfaces.Enabled

provides: Core.Picker

todo: Monkeypatch Element.position...
...
###
Core.Picker = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Enabled
    Interfaces.Children
  ]
  Binds: ['show','hide','delegate']
  Attributes: {
    class: {
      value: GDotUI.Theme.Picker.class
    }
    offset: {
      value: GDotUI.Theme.Picker.offset
      setter: (value) ->
        value
    }
    position: {
      value: {x:'auto',y:'auto'}
      validator: (value) ->
        value.x? and value.y?
    }
    event: {
      value: GDotUI.Theme.Picker.event
      setter: (value, old) ->
        value
    }
    content: {
      value: null
      setter: (value, old)->
        if old?
          if old["$events"]
            old.removeEvent 'change', @delegate
          @removeChild old
        @addChild value
        if value["$events"]
          value.addEvent 'change', @delegate
        value
    }
    picking: {
      value: GDotUI.Theme.Picker.picking
    }
  }
  create: ->
    @base.setStyle 'position', 'absolute'
  ready: ->
    # Below to Element.position monkeypatch
    winsize = window.getSize()
    winscroll = window.getScroll()
    asize = @attachedTo.getSize()
    position = @attachedTo.getPosition()
    size = @base.getSize()
    x = ''
    y = ''
    if @position.x is 'auto' and @position.y is 'auto'
      if (position.x+size.x+asize.x) > (winsize.x-winscroll.x) then x = 'left' else x = 'right'          
      if (position.y+size.y+asize.y) > (winsize.y-winscroll.y) then y = 'top' else y = 'bottom'
      if not ((position.y+size.y/2) > (winsize.y-winscroll.y)) and not ((position.y-size.y) < 0) then y = 'center'    
      position = {x:x,y:y}
    else
      position = @position
    
    ofa = {}
                    
    switch position.x
      when 'center'
        if position.y isnt 'center'
          ofa.x = -size.x/2
      when 'left'
        ofa.x = -(@offset+size.x)
      when 'right'
        ofa.x = @offset
    switch position.y
      when 'center'
        if position.x isnt 'center'
          ofa.y = -size.y/2
      when 'top'
        ofa.y = -(@offset+size.y)
      when 'bottom'
        ofa.y = @offset
    # endpatch
    @base.position {
      relativeTo: @attachedTo
      position: position
      offset: ofa
    }
  attach: (el,auto) ->
    auto = if auto? then auto else true
    if @attachedTo?
      @detach()
    @attachedTo = el
    if auto
      el.addEvent @event, @show
  detach: ->
    if @attachedTo?
      @attachedTo.removeEvent @event, @show
      @attachedTo = null
  delegate: ->
    if @attachedTo?
      @attachedTo.fireEvent 'change', arguments
  show: (e) ->
    document.body.grab @base
    if @attachedTo?
      @attachedTo.addClass @picking
    if e? then if e.stop? then e.stop()
    @base.addEvent 'outerClick', @hide
  hide: (e,force) ->
    if force?
      if @attachedTo?
          @attachedTo.removeClass @picking
        @base.dispose()
    else if e?
      if @base.isVisible() and not @base.hasChild(e.target)
        if @attachedTo?
          @attachedTo.removeClass @picking
        @base.dispose()
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
  Attributes: {
    selected: {
      getter: ->
        @items.filter(((item) ->
          if item.base.hasClass @options.selected then true else false
        ).bind(@))[0]
      setter: (value, old) ->
        if value?
          if old != value
            if old
              old.base.removeClass @options.selected
            value.base.addClass @options.selected
        value
        
    }
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
  ready: ->
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
  addItem: (li) -> 
    @items.push li
    @base.grab li
    li.addEvent 'select', ( (item,e)->
      @set 'selected', item 
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
}


###
---

name: Core.Slot

description: iOs style slot control.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Iterable.List

provides: Core.Slot

todo: horizontal/vertical, interfaces.size etc
...
###
Core.Slot = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Enabled
  Attributes: {
    class: {
      value: GDotUI.Theme.Slot.class
    }
  }
  Binds:[
    'check'
    'complete'
  ]
  Delegates:{
    'list':[
      'addItem'
      'removeAll'
      'select'
    ]
  }
  create: ->
    @overlay = new Element 'div', {'text':' '}
    @overlay.addClass 'over'
    @list = new Iterable.List()
    @list.base.addEvent 'addedToDom', @update.bind @
    @list.addEvent 'selectedChange', ((item) ->
      @update()
      @fireEvent 'change', item.newVal
    ).bind @
    @base.setStyle 'overflow', 'hidden'
    @base.setStyle 'position', 'relative'
    @list.base.setStyle 'position', 'relative'
    @list.base.setStyle 'top', '0'
    @overlay.setStyles {
      'position': 'absolute'
      'top': 0
      'left': 0
      'right': 0
      'bottom': 0
    }
    @overlay.addEvent 'mousewheel',@mouseWheel.bind @
    @drag = new Drag @list.base, {modifiers:{x:'',y:'top'},handle:@overlay}
    @drag.addEvent 'drag', @check
    @drag.addEvent 'beforeStart',( ->
      if not @enabled
        @disabledTop = @list.base.getStyle 'top' 
      @list.base.removeTransition()
    ).bind @
    @drag.addEvent 'complete', ( ->
      @dragging = off
      @update()
    ).bind @
  ready: ->
    @base.adopt @list, @overlay
  check: (el,e) ->
    if @enabled
      @dragging = on
      lastDistance = 1000
      lastOne = null
      @list.items.each ((item,i) ->
        distance = -item.base.getPosition(@base).y + @base.getSize().y/2
        if distance < lastDistance and distance > 0 and distance < @base.getSize().y/2
          @list.set 'selected', item
      ).bind @
    else
      el.setStyle 'top', @disabledTop
  mouseWheel: (e) ->
    if @enabled
      e.stop()
      if @list.selected?
        index = @list.items.indexOf @list.selected
      else
        if e.wheel is 1
          index = 0
        else
          index = 1
      if index+e.wheel >= 0 and index+e.wheel < @list.items.length 
        @list.set 'selected', @list.items[index+e.wheel]
      if index+e.wheel < 0
        @list.set 'selected', @list.items[@list.items.length-1]
      if index+e.wheel > @list.items.length-1
        @list.set 'selected', @list.items[0]
  update: ->
    if not @dragging
      @list.base.addTransition()
      if @list.selected?
        @list.base.setStyle 'top',-@list.selected.base.getPosition(@list.base).y+@base.getSize().y/2-@list.selected.base.getSize().y/2
}


###
---

name: Core.Toggler

description: iOs style checkboxes

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled
  - Interfaces.Size

provides: Core.Toggler

...
###
Core.Toggler = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: GDotUI.Theme.Toggler.class
    }
    onLabel: {
      value: GDotUI.Theme.Toggler.onText
      setter: (value) ->
        @onDiv.set 'text', value
    }
    offLabel: {
      value: GDotUI.Theme.Toggler.offText
      setter: (value) ->
        @offDiv.set 'text', value
    }
    onClass: {
      value: GDotUI.Theme.Toggler.onClass
      setter: (value, old) ->
        @onDiv.removeClass old
        @onDiv.addClass value
        value
    }
    offClass: {
      value: GDotUI.Theme.Toggler.offClass
      setter: (value, old) ->
        @offDiv.removeClass old
        @offDiv.addClass value
        value
    }
    separatorClass: {
      value: GDotUI.Theme.Toggler.separatorClass
      setter: (value, old) ->
        @separator.removeClass old
        @separator.addClass value
        value
    }
    checked: {
      value: on
      setter: (value) ->
        @base.fireEvent 'change', value
        value
    }
  }
  update: ->
    if @size
      $$(@onDiv,@offDiv,@separator).setStyles {
        width: @size/2
      }
      @base.setStyle 'width', @size
    if @checked
      @separator.setStyle 'left', @size/2
    else
      @separator.setStyle 'left', 0
    @offDiv.setStyle 'left', @size/2
  create: ->
    @base.setStyle 'position','relative'
    @onDiv = new Element 'div'
    @offDiv = new Element 'div'
    @separator = new Element 'div', {html: '&nbsp;'}
    @base.adopt @onDiv, @offDiv, @separator

    $$(@onDiv,@offDiv,@separator).setStyles {
      'position':'absolute'
      'top': 0
      'left': 0
    }
    
    @base.addEvent 'click', ( ->
       if @enabled
         if @checked
          @set 'checked', no
         else
          @set 'checked', yes
    ).bind @
    
}


###
---

name: Core.Overlay

description: Overlay for modal dialogs and stuff.

license: MIT-style license.

requires:
  - GDotUI
  - Core.Abstract
  - Interfaces.Enabled

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
      validator: (value) ->
        typeOf(Number.from(value)) is 'number'
    }
  }
  create: ->
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


###
---

name: Core.Tab

description: Tab element for Core.Tabs.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract

provides: Core.Tab

...
###
Core.Tab = new Class {
  Extends: Core.Abstract
  Attributes: {
    class: {
      value: GDotUI.Theme.Tab.class
    }
    label: {
      value: ''
      setter: (value) ->
        @base.set 'text', value
        value
    }
    activeClass: {
      value: GDotUI.Theme.Global.active
    }
  }
  create: ->
    @base.addEvent 'click', ( ->
      @fireEvent 'activate', @
    ).bind @
    @base.adopt @label
  activate: (event) ->
    if event
      @fireEvent 'activated', @
    @base.addClass @activeClass 
  deactivate: (event) ->
    if event
      @fireEvent 'deactivated', @
    @base.removeClass @activeClass
}


###
---

name: Core.Tabs

description: Tab navigation element.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Core.Tab 

provides: Core.Tabs

...
###
Core.Tabs = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Children
  Binds:['change']
  Attributes: {
    class: {
      value:  GDotUI.Theme.Tabs.class
    }
    active: {
      setter: (value, old) ->
        if not old?
          value.activate(false)
        else
          if old isnt value
            old.deactivate(false)
          value.activate(false)
        value
    }
  }
  add: (tab) ->
    if not @hasChild tab
      @addChild tab
      tab.addEvent 'activate', @change
  remove: (tab) ->
    if @hasChild tab
      @removeChild tab
  change: (tab) ->
    if tab isnt @active
      @set 'active', tab
      @fireEvent 'change', tab
  getByLabel: (label) ->
    (@children.filter (item, i) ->
      if item.label is label
        true
      else
        false)[0]
}


###
---

name: Core.Push

description: Toggle button 'push' element.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Button

provides: Core.Push

...
###
Core.Push = new Class {
  Extends: Core.Button
  Attributes: {
    state: {
      getter: ->
        @base.hasClass 'pushed' 
    }
    label: {
      value: GDotUI.Theme.Push.label
    }
    class: {
      value: GDotUI.Theme.Push.class
    }
  }
  on: ->
    @base.addClass 'pushed'
  off: ->
    @base.removeClass 'pushed'
  create: ->
    @parent()
    @base.addEvent 'click', ( ->
      if @enabled
        @base.toggleClass 'pushed'
    ).bind @  
}


###
---

name: Core.PushGroup

description: PushGroup element.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Children
  - Interfaces.Enabled
  - Interfaces.Size

provides: Core.PushGroup

todo: setActive into set 'active'
...
###
Core.PushGroup = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Children
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: GDotUI.Theme.PushGroup.class
    }
  }
  update: ->
    buttonwidth = Math.floor(@size / @children.length)
    @children.each (btn) ->
      btn.set 'size', buttonwidth
    if last = @children.getLast()
      last.set 'size', @size-buttonwidth*(@children.length-1)
  initialize: (options) ->
    @active = null
    @parent options 
  setActive: (item) ->
    if @active isnt item
      @children.each (btn) ->
        if btn isnt item
          btn.off()
          btn.unsupress()
        else
          btn.on()
          btn.supress()
      @active = item
      @fireEvent 'change', item
  removeItem: (item) ->
    if @hasChild item
      item.removeEvents 'invoked'
      @removeChild item
  addItem: (item) ->
    if not @hasChild item
      item.set 'minSize', 0
      item.addEvent 'invoked', ( (it) ->
        @setActive it
        @fireEvent 'change', it
      ).bind @
      @addChild item
    @update()
}


###
---

name: Dialog.Prompt

description: Select Element

license: MIT-style license.

requires: [Core.Abstract]

provides: Dialog.Prompt

...
###
Dialog.Prompt = new Class {
  Extends:Core.Abstract
  Delegates: {
    picker: ['show','hide','attach']
  }
  Attributes: {
    class: {
      value: 'dialog-prompt'
    }
    label: {
      value: ''
      setter: (value) ->
        @labelDiv.set 'text', value
    }
    buttonLabel: {
      value: 'Ok'
      setter: (value) ->
        @button.set 'label', value
    }
    labelClass: {
      value: 'dialog-prompt-label'
      setter: (value, old) ->
        value = String.from value
        @labelDiv.removeClass old
        @labelDiv.addClass value
        value
    }
  }
  initialize: (options) ->
    @parent options
  create: ->
    @labelDiv = new Element 'div'
    @input = new Element 'input',{type:'text'}
    @button = new Core.Button()
    @base.adopt @labelDiv, @input, @button
    @picker = new Core.Picker()
    @picker.set 'content', @base
    @button.addEvent 'invoked', ((el,e)->
      @fireEvent 'invoked', @input.get('value')
    ).bind @
}


###
---

name: Data.Select

description: Select Element

license: MIT-style license.

requires: [Core.Abstract, GDotUI, Interfaces.Controls, Interfaces.Enabled, Interfaces.Children, Iterable.List, Dialog.Prompt]

provides: [Data.Select]

...
###
Data.Select = new Class {
  Extends:Core.Abstract
  Implements:[ Interfaces.Controls, Interfaces.Enabled, Interfaces.Size, Interfaces.Children]
  Attributes: {
    class: {
      value: 'select'
    }
    default: {
      value: ''
      setter: (value, old) ->
        if @text.get('text') is (old or '')
          @text.set 'text', value
        value
    }
    selected: {
      getter: ->
        @list.get 'selected'
    }
    editable: {
      value: yes
      setter: (value) ->
        if value
          @adoptChildren  @removeIcon, @addIcon
        else
          document.id(@removeIcon).dispose()
          document.id(@addIcon).dispose()
        value
          
    }
  }
  getValue: ->
    li = @list.get('selected')
    if li?
      li.label
  setValue: (value) ->
    @list.set 'selected', @list.getItemFromTitle(value)
  update: ->
    @list.base.setStyle 'width', if @size < @minSize then @minSize else @size
  create: ->
    @base.setStyle 'position', 'relative'
    @text = new Element('div.text')
    @text.setStyles {
      position: 'absolute'
      top: 0
      left: 0
      right: 0
      bottom: 0
      'z-index': 0
      overflow: 'hidden'
    }
    @addIcon = new Core.Icon()
    @addIcon.base.addClass 'add'
    @addIcon.base.set 'text', '+'
    @removeIcon = new Core.Icon()
    @removeIcon.base.set 'text', '-'
    @removeIcon.base.addClass 'remove'
    $$(@addIcon.base,@removeIcon.base).setStyles {
      'z-index': '1'
      'position': 'relative'
    }
    @removeIcon.addEvent 'invoked',( (el,e)->
      e.stop()
      if @enabled
        @removeItem @list.get('selected')
        @text.set 'text', @default or ''
    ).bind @
    @addIcon.addEvent 'invoked',( (el,e)->
      e.stop()
      if @enabled
        @prompt.show()
    ).bind @
    
    @picker = new Core.Picker({offset:0,position:{x:'center',y:'bottom'}})
    @picker.attach @base
    @list = new Iterable.List({class:'select-list'})
    @picker.set 'content', @list
    @base.adopt @text
    
    @prompt = new Dialog.Prompt();
    @prompt.set 'label', 'Add item:'
    @prompt.attach @base, false
    @prompt.addEvent 'invoked', ((value) ->
      if value
        item = new Iterable.ListItem {label:value,removeable:false,draggable:false}
        @addItem item
        @list.set 'selected', item
      @prompt.hide null, yes
    ).bind @
    
    @list.addEvent 'selectedChange', ( ->
      item = @list.selected
      @text.set 'text', item.label
      @fireEvent 'change', item.label
      @picker.hide null, yes
    ).bind @
    @update()
    
  addItem: (item) ->
    item.base.set 'class', 'select-item'
    @list.addItem item
  removeItem: (item) ->
    @list.removeItem item
}


###
---

name: Data.Abstract

description: Abstract base class for data elements.

license: MIT-style license.

requires: [GDotUI, Interfaces.Mux]

provides: Data.Abstract

...
###
Data.Abstract = new Class {
  Implements:[Events
              Interfaces.Mux]
  Attributes: {
    class: {
      setter: (value, old) ->
        @base.removeClass old
        @base.addClass value
        value
    }
  }
  initialize: (options) ->
    @base = new Element 'div'
    @base.addEvent 'addedToDom', @ready.bind @
    @mux()
    @create()
    @setAttributes options
    @
  update: ->
    console.log 'update'
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
  Implements: Interfaces.Size  
  Attributes: {
    class: {
      value: GDotUI.Theme.Text.class
    }
  }
  initialize: (options) ->
    @parent options
  update: ->
    @text.setStyle 'width', @size
  create: ->
    @text = new Element 'textarea'
    @base.grab @text
    @addEvent 'show', ( ->
      @text.focus()
      ).bind this
    @text.addEvent 'keyup',( (e) ->
      @fireEvent 'change', @text.get('value')
    ).bind this
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
  Extends: Core.Slider
  Attributes: {
    class: {
      value: GDotUI.Theme.Number.classes.base
    }
    bar: {
      value: GDotUI.Theme.Number.classes.bar
    }
    text: {
      value: GDotUI.Theme.Number.classes.text
      setter: (value, old) ->
        @textLabel.removeClass old
        @textLabel.addClass value
        value
    }
    range: {
      value: GDotUI.Theme.Number.range
    }
    reset: {
      value: GDotUI.Theme.Number.reset
    }
    steps: {
      value: GDotUI.Theme.Number.steps
    }
    label: {
      value: null
    }
  }
  create: ->
    @parent()
    @textLabel = new Element "div"
    @textLabel.setStyles {
      position: 'absolute'
      bottom: 0
      left: 0
      right: 0
      top: 0
    }
    @base.grab @textLabel
    @addEvent 'step',( (e) ->
      @fireEvent 'change', e
    ).bind @
  update: ->
    @textLabel.set 'text', if @label? then @label + " : " + @value else @value
}


###
---

name: Data.Color

description: Color data element. ( color picker )

license: MIT-style license.

requires: [Data.Abstract, GDotUI, Interfaces.Enabled, Interfaces.Children, Data.Number]

provides: Data.Color

...
###
Data.Color = new Class {
  Extends:Data.Abstract
  Implements: [Interfaces.Enabled,Interfaces.Children, Interfaces.Size]
  Binds: ['change']
  Attributes: {
    class: {
      value: GDotUI.Theme.Color.class
    }
  }
  options:{
    wrapper: GDotUI.Theme.Color.wrapper
  }
  initialize: (options) ->
    @parent options

    @angle = 0
    @radius = 0    
    
    @hue = 0
    @saturation = 0
    @brightness = 100
    
    @center = {}
    @
    
  create: ->
    
    @hslacone = $(document.createElement('canvas'))
    @background = $(document.createElement('canvas'))
    @wrapper = new Element('div').addClass @options.wrapper
   
    @knob=new Element('div').set 'id', 'xyknob'
    @knob.setStyles {
      'position':'absolute'
      'z-index': 1
      }
      
    @colorData = new Data.Color.SlotControls()
    @colorData.addEvent 'change', ( ->
      @fireEvent 'change', arguments
    ).bind @
    @base.adopt @wrapper

    @colorData.lightnessData.addEvent 'change',( (step) ->
      @hslacone.setStyle 'opacity',step/100
    ).bind @

    @colorData.hueData.addEvent 'change', ((value) ->
      @positionKnob value, @colorData.get('saturation')
    ).bind @
    
    @colorData.saturationData.addEvent 'change', ((value) ->
      @positionKnob @colorData.get('hue'), value
    ).bind @
    
    @background.setStyles {
      'position': 'absolute'
      'z-index': 0
    }
    
    @hslacone.setStyles {
      'position': 'absolute'
      'z-index': 1
    }
    
    @xy = new Drag.Move @knob
    
    @wrapper.adopt @background, @hslacone, @knob
    @base.grab @colorData
  drawHSLACone: (width,brightness) ->
    ctx = @background.getContext '2d'
    ctx.fillStyle = "#000";
    ctx.beginPath();
    ctx.arc(width/2, width/2, width/2, 0, Math.PI*2, true); 
    ctx.closePath();
    ctx.fill();
    ctx = @hslacone.getContext '2d'
    ctx.translate width/2, width/2
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
  
  update: ->  
    @hslacone.set 'width', @size
    @hslacone.set 'height', @size
    @background.set 'width', @size
    @background.set 'height', @size
    @wrapper.setStyle 'height', @size
    @drawHSLACone @size, 100
    @colorData.set 'size', @size
    
    @knobSize = @knob.getSize()
    @halfWidth = @size/2
    @center = {x: @halfWidth, y:@halfWidth}
    @positionKnob @colorData.get('hue'), @colorData.get('saturation')
  positionKnob: (hue,saturation) ->
    @radius = saturation/100*@halfWidth
    @angle = -((180-hue)*(Math.PI/180))
    @knob.setStyle 'top', -Math.sin(@angle)*@radius-@knobSize.y/2+@center.y
    @knob.setStyle 'left', -Math.cos(@angle)*@radius-@knobSize.x/2+@center.x
  ready: ->
    @update()
    @xy.addEvent 'beforeStart',((el,e) ->
        @lastPosition = el.getPosition(@wrapper)
      ).bind @
    @xy.addEvent 'drag', ((el,e) ->
      if @enabled
        position = el.getPosition(@wrapper)
        
        x = @center.x-position.x-@knobSize.x/2
        y = @center.y-position.y-@knobSize.y/2
        
        @radius = Math.sqrt(Math.pow(x,2)+Math.pow(y,2))
        @angle = Math.atan2(y,x)
        
        if @radius > @halfWidth
          el.setStyle 'top', -Math.sin(@angle)*@halfWidth-@knobSize.y/2+@center.y
          el.setStyle 'left', -Math.cos(@angle)*@halfWidth-@knobSize.x/2+@center.x
          @saturation = 100
        else
          sat =  Math.round @radius 
          @saturation = Math.round((sat/@halfWidth)*100)
        
        an = Math.round(@angle*(180/Math.PI))
        @hue = if an < 0 then 180-Math.abs(an) else 180+an
        @colorData.set 'hue', @hue
        @colorData.set 'saturation', @saturation
      else
        el.setPosition @lastPosition
    ).bind @
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
  Implements: [Interfaces.Enabled,Interfaces.Children,Interfaces.Size]
  Attributes: {
    class: {
      value: GDotUI.Theme.Color.controls.class
    }
    hue: {
      value: 0
      setter: (value) ->
        @hueData.set 'value', value
        value
      getter: ->
        @hueData.value
    }
    saturation: {
      value: 0
      setter: (value) ->
        @saturationData.set 'value', value
        value
      getter: ->
        @saturationData.value
    }
    lightness: {
      value: 100
      setter: (value) ->
        @lightnessData.set 'value', value
        value
      getter: ->
        @lightnessData.value
    }
    alpha: {
      value: 100
      setter: (value) ->
        @alphaData.set 'value', value
        value
      getter: ->
        @alphaData.value
    }
    type: {
      value: 'hex'
      setter: (value) ->
        @col.children.each (item) ->
          if item.label == value
            @col.setActive item
        , @
        value
      getter: ->
        if @col.active?
          @col.active.label
    }
  }
  update: ->
    hue = @get 'hue'
    saturation = @get 'saturation'
    lightness = @get 'lightness'
    type = @get 'type'
    alpha = @get 'alpha'
    if hue? and saturation? and lightness? and type? and alpha?
      @fireEvent 'change', {color:$HSB(hue,saturation,lightness), type:type, alpha:alpha} 
  create: ->
    @addEvent 'sizeChange',( ->
      @col.set 'size', @size
      @hueData.set 'size', @size
      @saturationData.set 'size', @size
      @lightnessData.set 'size', @size
      @alphaData.set 'size', @size
    ).bind @
    @hueData = new Data.Number {range:[0,360],reset: off, steps: 360, label:'Hue'}
    @hueData.addEvent 'change', ((value) ->
      @update() 
    ).bind @
    @saturationData = new Data.Number {range:[0,100],reset: off, steps: 100 , label:'Saturation'}
    @saturationData.addEvent 'change', ((value) ->
      @update() 
    ).bind @
    @lightnessData = new Data.Number {range:[0,100],reset: off, steps: 100, label:'Lightness'}
    @lightnessData.addEvent 'change', ((value) ->
      @update() 
    ).bind @
    @alphaData = new Data.Number {range:[0,100],reset: off, steps: 100, label:'Alpha'}
    @alphaData.addEvent 'change', ((value) ->
      @update() 
    ).bind @
    @col = new Core.PushGroup()
    Data.Color.ReturnValues.options.each ((item) ->
      @col.addItem new Core.Push({label:item.label})
    ).bind @
    @col.addEvent 'change', ((value) ->
      @update()
    ).bind @
    @adoptChildren @hueData, @saturationData, @lightnessData, @alphaData, @col
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
  Attributes: {
    class: {
      value: GDotUI.Theme.Date.class
    }
    value: {
      value: new Date()
      setter: (value) ->
        @value = value
        @updateSlots()
        value
        
    }
  }
  options:{
    yearFrom: GDotUI.Theme.Date.yearFrom
  }
  create: ->
    @days = new Core.Slot()
    @month = new Core.Slot()
    @years = new Core.Slot()
    @populate()
    @addEvents()
  addEvents: ->
    @years.addEvent 'change', ( (item) ->
      @value.set 'year', item.label
      @update()
    ).bind @
    @month.addEvent 'change', ( (item) ->
      @value.set 'month', item.label
      @update()
    ).bind @
    @days.addEvent 'change', ( (item) ->
      @value.set 'date', item.label
      @update()
    ).bind @
  populate: ->
    i = 0
    while i < 30
      item = new Iterable.ListItem {label:i+1,removeable:false}
      @days.addItem item
      i++
    i = 0
    while i < 12
      item = new Iterable.ListItem {label:i+1,removeable:false}
      @month.addItem item
      i++
    i = @options.yearFrom
    while i <= new Date().get('year')
      item = new Iterable.ListItem {label:i,removeable:false}
      @years.addItem item
      i++
  ready: ->
    @base.adopt @years, @month, @days
  update: ->
    @fireEvent 'change', @value
  updateSlots: ->
    cdays = @value.get 'lastdayofmonth'
    listlength = @days.list.items.length
    if cdays > listlength
      i = listlength+1
      while i <= cdays
        item=new Iterable.ListItem {label:i}
        item.value = i
        @days.addItem item
        i++
    else if cdays < listlength
      i = listlength
      while i > cdays
        @days.list.removeItem @days.list.items[i-1]
        i--
    @days.list.set 'selected', @days.list.items[@value.get('date')-1]
    @month.list.set 'selected', @month.list.items[@value.get('month')]
    @years.list.set 'selected', @years.list.getItemFromTitle(@value.get('year'))
}


###
---

name: Data.Time

description: Time picker element with Core.Slot-s

license: MIT-style license.

requires: [Data.Abstract, GDotUI, Interfaces.Children]

provides: Data.Time

...
###
Data.Time = new Class {
  Extends:Data.Abstract
  Implements: [Interfaces.Enabled,Interfaces.Children]
  Attributes: {
    class: {
      value: GDotUI.Theme.Date.Time.class
    }
    value: {
      value: new Date()
      setter: (value) ->
        @value = value
        @updateSlots()
        value
        
    }
  }
  create: ->
    @hours = new Core.Slot()
    @minutes = new Core.Slot()
    @populate()
    @addEvents()
    @
  populate: ->
    i = 0
    while i < 24
      item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
      item.value = i
      @hours.addItem item
      i++
    i = 0
    while i < 60
      item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
      item.value = i
      @minutes.addItem item
      i++
  update: ->
    @fireEvent 'change', @value
  addEvents: ->
    @hours.addEvent 'change', ( (item) ->
      @value.set 'hours', item.value
      @update()
    ).bind @
    @minutes.addEvent 'change', ( (item) ->
      @value.set 'minutes', item.value
      @update()
    ).bind @
  ready: ->
    @adoptChildren @hours, @minutes
  updateSlots: ->
    @hours.list.set 'selected', @hours.list.items[@value.get('hours')]
    @minutes.list.set 'selected', @minutes.list.items[@value.get('minutes')]
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
				@drag = new Drag.Ghost @base, {target:@handle, handle:@handle, remove:@options.removeClasses, droppables: @options.droppables, precalculate: on, pos:true}
			else
				@drag = new Drag.Float @base, {target:@handle, handle:@handle}
			@drag.addEvent 'drop', (->
				@fireEvent 'dropped', arguments
			).bindWithEvent @
}


###
---

name: Iterable.ListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

requires: [GDotUI, Interfaces.Draggable]
...
###
Iterable.ListItem = new Class {
  Extends:Core.Abstract
  Implements: [Interfaces.Draggable
               Interfaces.Enabled ]
  Attributes: {
    label: {
      value: ''
      setter: (value) ->
        @title.set 'text', value
        value
    }
    class: {
      value: GDotUI.Theme.ListItem.class
    }
  }
  options:{
    classes:{
      title: GDotUI.Theme.ListItem.title
      subtitle: GDotUI.Theme.ListItem.subTitle
    }
    title:''
    subtitle:''
    draggable: off
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
    @base.setStyle 'position','relative'
    #@remove = new Core.Icon {image: @options.icons.remove}
    #@handles = new Core.Icon {image: @options.icons.handle}
    #@handles.base.addClass  @options.classes.handle
    
    #$$(@remove.base,@handles.base).setStyle 'position','absolute'
    @title = new Element 'div'
    @subtitle = new Element 'div'
    @base.adopt @title,@subtitle
    #if @options.removeable
    #  @base.grab @remove
    #if @options.sortable
    #  @base.grab @handle
    @base.addEvent @options.selectEvent, ( (e)->
      @fireEvent 'select', [@,e]
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
    #@remove.addEvent 'invoked', ( ->
    #  @fireEvent 'delete', @
    #).bindWithEvent @
    @
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
      #handSize = @handles.base.getSize()
      #remSize = @remove.base.getSize()
      baseSize = @base.getSize()
      #@remove.base.setStyles {
      #  "right":-remSize.x
      #  "top":(baseSize.y-remSize.y)/2
      #  }
      #@handles.base.setStyles {
      #  "left":-handSize.x,
      #  "top":(baseSize.y-handSize.y)/2
      #  }
      @parent()
      if @options.draggable
        @drag.addEvent 'beforeStart',( ->
          #recalculate drops
          @fireEvent 'select', @
          ).bindWithEvent @
}


###
---

name: Data.DateTime

description:  Date & Time picker element with Core.Slot-s

license: MIT-style license.

requires: [Data.Abstract, GDotUI, Core.Slot, Iterable.ListItem]

provides: Data.DateTime

...
###
Data.DateTime = new Class {
  Extends:Data.Abstract
  Implements: [Interfaces.Enabled,Interfaces.Children]
  Attributes: {
    class: {
      value: GDotUI.Theme.Date.DateTime.class
    }
    value: {
      value: new Date()
      setter: (value) ->
        @value = value
        @updateSlots()
        value
        
    }
  }
  options:{
    yearFrom: GDotUI.Theme.Date.yearFrom
  }
  create: ->
    @days = new Core.Slot()
    @month = new Core.Slot()
    @years = new Core.Slot()
    @hours = new Core.Slot()
    @minutes = new Core.Slot()
    @populate()
    @addEvents()
    @
  populate: ->
    i = 0
    while i < 24
      item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
      item.value = i
      @hours.addItem item
      i++
    i = 0
    while i < 60
      item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
      item.value = i
      @minutes.addItem item
      i++
    i = 0
    while i < 30
      item = new Iterable.ListItem {label:i+1,removeable:false}
      item.value = i+1
      @days.addItem item
      i++
    i = 0
    while i < 12
      item = new Iterable.ListItem {label:i+1,removeable:false}
      item.value = i
      @month.addItem item
      i++
    i = @options.yearFrom
    while i <= new Date().getFullYear()
      item = new Iterable.ListItem {label:i,removeable:false}
      item.value = i
      @years.addItem item
      i++
  update: ->
    @fireEvent 'change', @value
  addEvents: ->
    @hours.addEvent 'change', ( (item) ->
      @value.set 'hours', item.value
      @update()
    ).bind @
    @minutes.addEvent 'change', ( (item) ->
      @value.set 'minutes', item.value
      @update()
    ).bind @
    @years.addEvent 'change', ( (item) ->
      @value.set 'year', item.value
      @update()
    ).bind @
    @month.addEvent 'change', ( (item) ->
      @value.set 'month', item.value
      @update()
    ).bind @
    @days.addEvent 'change', ( (item) ->
      @value.set 'date', item.value
      @update()
    ).bind @
    i = 0
  ready: ->
    @adoptChildren @years, @month, @days, @hours, @minutes
  updateSlots: ->
    cdays = @value.get 'lastdayofmonth'
    console.log @value.getDate(), 'hey',@value.get('hours')
    listlength = @days.list.items.length
    if cdays > listlength
      i = listlength+1
      while i <= cdays
        item=new Iterable.ListItem {label:i}
        item.value = i
        @days.addItem item
        i++
    else if cdays < listlength
      i = listlength
      while i > cdays
        @days.list.removeItem @days.list.items[i-1]
        i--
    @days.list.set 'selected', @days.list.items[@value.get('date')-1]
    @month.list.set 'selected', @month.list.items[@value.get('month')]
    @years.list.set 'selected', @years.list.getItemFromTitle(@value.get('year'))
    @hours.list.set 'selected', @hours.list.items[@value.get('hours')]
    @minutes.list.set 'selected', @minutes.list.items[@value.get('minutes')]
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

name: Data.Unit

description: Color data element. ( color picker )

license: MIT-style license.

requires: [Data.Abstract, GDotUI, Data.Select, Data.Number]

provides: Data.Unit

...
###
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
  Implements: Interfaces.Size
  Attributes: {
    class: {
      value: GDotUI.Theme.Unit.class
    }
  }
  initialize: (options) ->
    @parent options
  update: ->
    @number.set 'size', @size-@sel.get('size')
  create: ->
    @value = 0
    @selectSize = 80
    @number = new Data.Number {range:[-50,50],reset: on, steps: [100]}
    @sel = new Data.Select({size: 80})
    Object.each UnitList,((item) ->
      @sel.addItem new Iterable.ListItem({label:item,removeable:false,draggable:false})
    ).bind @
    @number.addEvent 'change', ((value) ->
      @value = value
      @fireEvent 'change', String(@value)+@sel.getValue()
    ).bindWithEvent @
    @sel.setValue 'px'
    @sel.addEvent 'change', ( ->
      @fireEvent 'change', String(@value)+@sel.getValue()
    ).bindWithEvent @
    @base.adopt @number, @sel
    @update()
  setValue: (value) ->
    if typeof value is 'string'
      match = value.match(/(-?\d*)(.*)/)
      value = match[1]
      unit = match[2]
      @sel.setValue unit
      @number.set value
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
      tg.set 'checked' , @options.checked or false
      @base = tg.base
    if @options.type is "textarea"
      @base = new Element 'textarea', {name: @options.name}
    if @options.type is "select"
      select = new Data.Select {default: @options.name}
      @options.options.each ( (item) ->
        select.addItem new Iterable.ListItem {label:item.label}
      ).bind @
      @base = select.base
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
    @options = options
    @options.structure = GDotUI.Theme.Forms.Field.struct
    @parent options
    @
  create: ->
    h = new Hash @options.structure
    h.each ((value,key) ->
      @base = new Element key
      @createS value, @base
    ).bind @
    if @options.hidden
      @base.setStyle 'display', 'none'
  createS: (item,parent) ->
    if not parent?
      null
    else
      console.log typeOf(item)
      switch typeOf(item)
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
            console.log document.id(el)
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
    @options = options
    @parent options
  create: () ->
    delete @base
    @base = new Element 'fieldset'
    @legend = new Element 'legend', {text: @options.name}
    @base.grab @legend
    @options.inputs.each ( (item) ->
      @base.grab new Forms.Field(item)
    ).bind @
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
  Implements: Options
  Binds:['success', 'faliure']
  options:{
    data: {}
  }
  initialize: (options) ->
    @fieldsets = []
    @setOptions options
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
      
    @submit = new Core.Button {label:@options.submit}
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
  Delegates:{
    picker:['attach'
            'detach'
            'attachAndShow'
            ]
    data: ['setValue'
          'getValue'
          'disable'
          'enable']
  }
  Attributes: {
    type: {
      value: null
    }
  }
  update: ->
  initialize: (options) ->
    @setAttributes options
    @picker = new Core.Picker()
    @data = new Data[@type]()
    @picker.set 'content', @data
    @
}
Pickers.Color = new Pickers.Base {type:'Color'}
###
Pickers.Number = new Pickers.Base {type:'Number'}
Pickers.Time = new Pickers.Base {type:'Time'}
Pickers.Text = new Pickers.Base {type:'Text'}
Pickers.Date = new Pickers.Base {type:'Date'}
Pickers.DateTime = new Pickers.Base {type:'DateTime'}
Pickers.Table = new Pickers.Base {type:'Table'}
Pickers.Unit = new Pickers.Base {type:'Unit'}
#Pickers.Select = new Pickers.Base {type:'Select'}
Pickers.List = new Pickers.Base {type:'List'}
###

