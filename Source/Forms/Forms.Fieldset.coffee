###
---

name: Forms.Fieldset

description: 

license: MIT-style license.

requires: [Core.Abstract, Forms.Field]

provides: Forms.Fieldset

...
###
Forms.Fieldset: new Class {
  Extends:Core.Abstract
  options:{
    name:''
    inputs:[]
  }
  initialize: (options) ->
    @parent options
    this
  create: () ->
    delete @base
    @base: new Element 'fieldset'
    @legend: new Element 'legend', {text:@options.name}
    @base.grab(@legend)
    @options.inputs.each( ( (item) ->
      @base.grab new Forms.Field(item)
    ).bindWithEvent this )
}