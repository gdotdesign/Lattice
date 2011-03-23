###
---

name: Forms.Input

description: Input elements for Forms.

license: MIT-style license.

requires: GDotUI

provides: Forms.Input

...
###
Forms.Input = new Class {
  Implements:[Events
              Options]
  options:{
    type: ''
    name: ''
  }
  initialize: (options) ->
    @setOptions options
    @base = new Element 'div'
    @create()
    @
  create: () ->
    delete @base  
    if (@options.type is 'text' or @options.type is 'password' or @options.type is 'button')
      @base = new Element 'input', { type: @options.type, name: @options.name}
    if @options.type is 'checkbox'
      tg = new Core.Toggler()
      tg.base.setAttribute 'name', @options.name
      tg.base.setAttribute 'type', 'checkbox'
      tg.set 'checked' , @options.checked or false
      @base = tg.base
    if @options.type is "textarea"
      @base = new Element 'textarea', {name: @options.name}
    if @options.type is "select"
      select = new Data.Select {default: @options.name}
      @options.options.each ( (item) ->
        select.addItem new Iterable.ListItem {label:item.label}
      ).bind @
      @base = select.base
    if @options.type is "radio"
      @base = new Element 'div'
      @options.options.each ( (item,i) ->
        label = new Element 'label', {'text':item.label}
        input = new Element 'input', {type:'radio',name:@options.name, value:item.value}
        @base.adopt label, input
        ).bind @
    if @options.validate?
      $splat(@options.validate).each ( (val) ->
        if @options.type isnt "radio"
          @base.addClass val
      ).bind @
    @base
  toElement: ->
    @base
}
