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
  options:{
    class: GDotUI.Theme.Number.classes.base
    bar: GDotUI.Theme.Number.classes.bar
    text: GDotUI.Theme.Number.classes.text
    range: GDotUI.Theme.Number.range
    reset: GDotUI.Theme.Number.reset
    steps: GDotUI.Theme.Number.steps
  }
  initialize: (options) ->
    @parent options
  create: ->
    @parent()
    @text = new Element "div.#{@options.text}"
    @text.setStyles {
      position: 'absolute'
      bottom: 0
      left: 0
      right: 0
      top: 0
    }
    @base.grab @text
    @addEvent 'step',( (e) ->
      @text.set 'text', e
      @fireEvent 'change', e
    ).bind @
  getValue: ->
    if @options.reset
      @value
    else
      Math.round((Number.from(@progress.getStyle(@modifier))/@size)*@options.steps)
  setValue: (step) ->
    real = @set step
    @text.set 'text', real
}
