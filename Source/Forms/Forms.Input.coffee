###
---

name: Forms.Input

description: Input elements for Forms.

license: MIT-style license.

requires: Core.Abstract

provides: Forms.Input

...
###
Forms.Input = new Class {
  Extends:Core.Abstract
  options:{
    type: ''
    name: ''
  }
  initialize: (options) ->
    @parent options
  create: () ->
    delete @base  
    if (@options.type is 'text' or @options.type is 'password' or @options.type is 'checkbox' or @options.type is 'button')
      @base = new Element 'input', { type: @options.type, name: @options.name}
    if @options.type is "textarea"
      @base = new Element 'textarea', {name: @options.name}
    if @options.type is "select"
      @base = new Element 'select', {name: @options.name}
      @options.options.each ( (item) ->
        @base.grab new Element('option', {value:item.value,text:item.label})
      ).bind this
    if @options.type is "radio"
      @base = new Element 'div'
      @options.options.each ( (item,i) ->
        label = new Element 'label', {'text':item.label}
        input = new Element 'input', {type:'radio',name:@options.name, value:item.value}
        @base.adopt label, input
        ).bind this
    if @options.validate?
      $splat(@options.validate).each ( (val) ->
        if @options.type isnt "radio"
          @base.addClass val
      ).bind this
    @base
}
