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
  initialize: (options) ->
    @parent options
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
      @textLabel.set 'text', if @label? then @label + " : " + e else e
      @fireEvent 'change', e
    ).bind @
  getValue: ->
    if @reset
      @value
    else
      Math.round((Number.from(@progress.getStyle(@modifier))/@size)*@steps)
  setValue: (step) ->
    real = @parent step
    @textLabel.set 'text', if @label? then @label + " : " + real else real
}
