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
    scrollBase: null
    reset: off
    steps: 0
    range: [0,0]
    mode: 'horizontal'
    class: GDotUI.Theme.Slider.classes.base
    bar: GDotUI.Theme.Slider.classes.bar
    text: GDotUI.Theme.Slider.classes.text
  }
  initialize: (options) ->
    @parent options
  set: (position) ->
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
      @size = @options.size or Number.from getCSS("/\\.#{@options.class}.horizontal$/",'width').slice(0,-2)
      @progress.setStyles {
        top: 0
        width: 0
      }
    if @options.mode is 'vertical'
      @size = @options.size or Number.from getCSS("/\\.#{@options.class}.vertical$/",'height').slice(0,-2)
      modifiers = {x: '',y: 'height'}
      @modifier = 'height'
      @progress.setStyles {
        height: 0
        right: 0
      }
      
    @base.adopt @progress
    
    @drag = new Drag @progress, {handle:@base, modifiers:modifiers, invert: if @options.mode is 'vertical' then true else false}
    
    @drag.addEvent 'beforeStart', ( (el,e) ->
      if not @enabled
        @disabledTop = el.getStyle @modifier
    ).bind @
    @drag.addEvent 'drag', ( (el,e) ->
      if @enabled
        pos = Number.from el.getStyle(@modifier)
        if pos > @size
          el.setStyle @modifier, @width+"px"
          pos = @size
        @fireEvent 'step', Math.round((pos/@size)*100)
      else
        el.setStyle @modifier, @disabledTop
    ).bind @
    
    @base.addEvent 'mousewheel', ( (e) ->
      e.stop()
      offset = Number.from e.wheel
      pos = Number.from @progress.getStyle(@modifier)
      console.log offset, pos
      if pos+offset < 0
        console.log '<0'
        @progress.setStyle @modifier, 0+"px"
        pos = 0
      if pos+offset > @size
        console.log '> @width'
        @progress.setStyle @modifier, @size+"px"
        pos = pos+offset
      if not(pos+offset < 0) and not(pos+offset > @size)
        console.log 'in range'
        @progress.setStyle @modifier, (pos+offset/100*@size)+"px"
    ).bind @

}
