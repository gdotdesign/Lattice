###
---

name: Forms.Input

description: 

license: MIT-style license.

requires: Core.Abstract

provides: Forms.Input

...
###
Forms.Input: new Class {
  Extends:Core.Abstract
  options:{
    structure: GDotUI.Theme.Forms.Field.struct
    type: 'checkbox'
  }
  initialize: (options) ->
    @parent options
    this
  create: () ->
    delete @base  
    if (@options.type=='text' || @options.type=='password' || @options.type=='checkbox' || @options.type=='button')
      @base: new Element 'input', { type:@options.type, name:@options.name}
    if @options.type == "textarea"
      @base: new Element 'textarea', {name:@options.name}
    if @options.type == "select"
      @base: new Element 'select', {name:@options.name}
      @options.options.each ( (item) ->
        @base.grab new Element('option', {value:item.value,text:item.label})
      ).bind this
    if @options.type =="radio"
      @base: document.createDocumentFragment()
      @options.texts.each ( (it,i) ->
        label: new Element 'label', {'text':it}
        input: new Element 'input', {type:'radio',name:item.name,'value':item.values[i]}
        @base.appendChild input, label
        ).bind this
    if @options.validate?
      $splat(@options.validate).each ( (val) ->
        @base.addClass val
      ).bind this
    @base
}