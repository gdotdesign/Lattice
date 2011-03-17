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
  Delegates:{ 'slider':[
    'set'
    'setRange'
  ]}
  options:{
    reset: off
    steps: 100
    range: [0,0]
    mode: 'horizontal'
    class: GDotUI.Theme.Slider.classes.base
    bar: GDotUI.Theme.Slider.classes.bar
  }
  initialize: (options) ->
    @value = 0
    @parent options
  set: (position) ->
    if @options.reset
      @value = Number.from position
    else
      position = Math.round((position/@options.steps)*@size)
      percent = Math.round((position/@size)*@options.steps)
      if position < 0
        @progress.setStyle @modifier, 0+"px"
      if position > @size
        @progress.setStyle @modifier, @size+"px"
      if not(position < 0) and not(position > @size)
        @progress.setStyle @modifier, (percent/@options.steps)*@size+"px"
    console.log position, @size, @options.steps
    if @options.reset then @value else Math.round((position/@size)*@options.steps)
  create: ->
    @base.addClass @options.class
    @base.addClass @options.mode

    @progress = new Element "div.#{@options.bar}"

    @base.setStyle 'position', 'relative'
    @progress.setStyles {
      position: 'absolute'
      bottom: 0
      left: 0
    }
    
    if @options.mode is 'horizontal'
      @modifier = 'width'
      modifiers = {x: 'width',y:''}
      if @options.size?
        @size = @options.size
        @base.setStyle 'width', @size
      else
        @size = Number.from getCSS("/\\.#{@options.class}.horizontal$/",'width')
      @progress.setStyles {
        top: 0
        width: if @options.reset then @size/2 else 0
      }
    if @options.mode is 'vertical'
      if @options.size
        @size = Number.from @options.size
        @base.setStyle 'height', @size
      else
        Number.from getCSS("/\\.#{@options.class}.vertical$/",'height')
      modifiers = {x: '',y: 'height'}
      @modifier = 'height'
      @progress.setStyles {
        height: if @options.reset then @size/2 else 0
        right: 0
      }
      
    @base.adopt @progress
    
    @drag = new Drag @progress, {handle:@base, modifiers:modifiers, invert: if @options.mode is 'vertical' then true else false}
    
    @drag.addEvent 'beforeStart', ( (el,e) ->
      @lastpos = Math.round((Number.from(el.getStyle(@modifier))/@size)*@options.steps)
      if not @enabled
        @disabledTop = el.getStyle @modifier
    ).bind @
    
    @drag.addEvent 'complete', ( (el,e) ->
      if @options.reset
        if @enabled
          el.setStyle @modifier, @size/2+"px"
      @fireEvent 'complete'
    ).bind @
      
    @drag.addEvent 'drag', ( (el,e) ->
      if @enabled
        pos = Number.from el.getStyle(@modifier)
        offset = Math.round((pos/@size)*@options.steps)-@lastpos
        @lastpos = Math.round((Number.from(el.getStyle(@modifier))/@size)*@options.steps)
        if pos > @size
          el.setStyle @modifier, @size+"px"
          pos = @size
        else
          if @options.reset
            @value+=offset
        @fireEvent 'step', if @options.reset then @value else Math.round((pos/@size)*@options.steps)
      else
        el.setStyle @modifier, @disabledTop
    ).bind @
    
    @base.addEvent 'mousewheel', ( (e) ->
      e.stop()
      offset = Number.from e.wheel
      if @options.reset
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
          @progress.setStyle @modifier, (pos+offset/@options.steps*@size)+"px"
          pos = pos+offset
      @fireEvent 'step', if @options.reset then @value else Math.round((pos/@size)*@options.steps)
    ).bind @

}
