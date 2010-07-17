###
---

name: Data.Number

description: 

license: MIT-style license.

requires: [Data.Abstract, Core.Slider]

provides: Data.Number

...
###
Data.Number: new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Number.class
    range: GDotUI.Theme.Number.range
    reset: GDotUI.Theme.Number.reset
    steps: GDotUI.Theme.Number.steps
  }
  initialize: (options) ->
    @parent options
    this
  create: ->
    @base.addClass @options.class
    @text: new Element 'input', {'type':'text'}
    @text.set('value',0).setStyle 'width',GDotUI.Theme.Slider.length
    @slider: new Core.Slider {reset: @options.reset
                              range: @options.range
                              steps: @options.steps
                              mode:'vertical'}
  ready: ->
    @slider.knob.grab @text
    @base.adopt @slider
    @slider.knob.addEvent 'click', ( ->
      @text.focus()
    ).bindWithEvent this
    @slider.addEvent 'complete', ( (step) ->
      if @options.reset
        @slider.setRange [step-@options.steps/2, Number(step)+@options.steps/2]
      @slider.set step
      ).bindWithEvent this
    @slider.addEvent 'change', ( (step) ->
      if typeof(step) == 'object'
        @text.set 'value', 0
      else
        @text.set 'value', step
      @fireEvent 'change', step
      ).bindWithEvent this
    @text.addEvent 'change', ( ->
      step: Number @text.get('value')
      if @options.reset
        @slider.setRange [step-@options.steps/2,Number(step)+@options.steps/2]
      @slider.set step
    ).bindWithEvent this
    @text.addEvent 'mousewheel', ( (e) ->
      @slider.set Number(@text.get('value'))+e.wheel
    ).bindWithEvent this
    @parent()
  setValue: (step) ->
    if @options.reset
      @slider.setRange [step-@options.steps/2,Number(step)+@options.steps/2]
    @slider.set step
}