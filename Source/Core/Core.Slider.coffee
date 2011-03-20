###
---

name: Core.Slider

description: Slider element for other elements.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, GDotUI]

provides: [Core.Slider, ResetSlider]

...
###
Core.Slider = new Class {
  Extends:Core.Abstract
  Implements:[ Interfaces.Controls, Interfaces.Enabled ]
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
            @modifier = 'width'
            @drag.options.modifiers = {x: 'width',y:''}
            @drag.options.invert = false
            if not @size?
              size = Number.from getCSS("/\\.#{@get('class')}.horizontal$/",'width')
            @set 'size', size
            @base.setStyle 'height', Number.from getCSS("/\\.#{@get('class')}.horizontal$/",'height')
            @progress.setStyles {
              top: 0
              width: if @reset then @size/2 else 0
            }
          when 'vertical'
            @modifier = 'height'
            @drag.options.modifiers = {x: '',y: 'height'}
            @drag.options.invert = true
            if not @size?
              size = Number.from getCSS("/\\.#{@class}.vertical$/",'height')
            @set 'size', size
            @base.setStyle 'width', Number.from getCSS("/\\.#{@class}.vertical$/",'width')
            @progress.setStyles {
              height: if @reset then @size/2 else 0
              right: 0
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
      setter: (value) ->
        @base.setStyle @modifier, value
        value
    }
  }
  initialize: (options) ->
    @value = 0
    
    @parent options
  setValue: (position) ->
    if @get('reset')
      @value = Number.from position
    else
      position = Math.round((position/@get('steps'))*@size)
      percent = Math.round((position/@size)*@get('steps'))
      if position < 0
        @progress.setStyle @modifier, 0+"px"
      if position > @size
        @progress.setStyle @modifier, @size+"px"
      if not(position < 0) and not(position > @size)
        @progress.setStyle @modifier, (percent/@get('steps'))*@size+"px"
    console.log position, @size, @get('steps')
    if @get('reset') then @value else Math.round((position/@size)*@get('steps'))
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
      if @get('reset')
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
          el.setStyle @modifier, "#{@size}px"
          pos = @size
        else
          if @reset
            @value += offset
        @fireEvent 'step', if @reset then @value else Math.round((pos/@size)*@steps)
      else
        el.setStyle @modifier, @disabledTop
    ).bind @
    
    @base.addEvent 'mousewheel', ( (e) ->
      e.stop()
      offset = Number.from e.wheel
      if @get('reset')
        @value += offset
      else
        pos = Number.from @progress.getStyle(@modifier)
        if pos+offset < 0
          @progress.setStyle @modifier, 0+"px"
          pos = 0
        if pos+offset > @size
          @progress.setStyle @modifier, @size+"px"
          pos = pos+offset
        if not(pos+offset < 0) and not(pos+offset > @size)
          @progress.setStyle @modifier, (pos+offset/@get('steps')*@size)+"px"
          pos = pos+offset
      @fireEvent 'step', if @get('reset') then @value else Math.round((pos/@size)*@get('steps'))
    ).bind @

}
