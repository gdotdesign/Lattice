###
---

name: Data.Select

description: Color data element. ( color picker )

license: MIT-style license.

requires: Data.Abstract

provides: Data.Select

...
###
Data.Select: new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Select.class
    list: {}
  }
  initialize: (options) ->
    @parent(options)
  create: ->
    @base.addClass @options.class
    @select = new Element 'select'
    @base.grab @select
    new Hash(@options.list).each ( (value,key) ->
      option = new Element 'option'
      option.set 'value', value
      option.set 'text', key
      @select.grab option
    ).bind @
    @select.addEvent 'change', ( ->
      @value = @select.get 'value'
      @fireEvent 'change', @value
    ).bindWithEvent @
  setList: (list) ->
    @select.getElements("option").destroy()
    new Hash(list).each ( (value,key) ->
      option = new Element 'option'
      option.set 'value', value
      option.set 'text', key
      @select.grab option
    ).bind @
  setValue: (value) ->
    selected = @select.getElements "option[value=$value]"
    if selected[0]?
      @select.getElements("option").set 'selected', null
      selected.set 'selected', true
      @value = value
  getValue: ->
    if not @value?
      @value = @select.get 'value'
    @value
}
    
