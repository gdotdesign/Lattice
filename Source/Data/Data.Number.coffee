###
---

name: Data.Number

description: 

license: MIT-style license.

requires: [Data.Abstrac, Core.Slider]

provides: Data.Number

...
###
Data.Number: new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Number.class
  }
  initialize: (options) ->
    @parent options
    this
  create: ->
    @base.addClass @options.class
    @text: new Element 'input', {'type':'text'}
    @text.set('value',0).setStyle 'width',GDotUI.Theme.Slider.length
    @slider: new Core.Slider {reset: on
                              range:[-100,100]
                              steps:200
                              mode:'vertical'}
  ready: ->
    @slider.knob.grab @text
    @base.adopt @slider
    @slider.knob.addEvent 'click', ( ->
      @text.focus()
    ).bindWithEvent this
    @slider.addEvent 'complete', ( (step) ->
      @slider.setRange [step-100, Number(step)+100]
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
      @slider.setRange [step-100,Number(step)+100]
      @slider.set step
    ).bindWithEvent this
    @text.addEvent 'mousewheel', ( (e) ->
      @slider.set Number(@text.get('value'))+e.wheel
    ).bindWithEvent this
    @parent()
  setValue: (step) ->
    @slider.setRange [step-100,Number(step)+100]
    @slider.set step
}