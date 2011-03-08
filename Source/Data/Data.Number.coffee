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
