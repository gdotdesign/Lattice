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
  Implements: [
    Events
    Options
  ]
  options:{
    name:''
    inputs:[]
  }
  initialize: (options) ->
    @setOptions options
    @base = new Element 'fieldset'
    @legend = new Element 'legend', {text: @options.name}
    @base.grab @legend
    @options.inputs.each ( (item) ->
      @base.grab new Forms.Field(item)
    ).bind @
    @
  toElement: ->
    @base
}
