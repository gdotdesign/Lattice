###
---

name: Data.Unit

description: Color data element. ( color picker )

license: MIT-style license.

requires: Data.Abstract

provides: Data.Unit

...
###
Data.Unit: new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Unit.class
  }
  initialize: (options) ->
    @parent(options)
  create: ->
    @base.addClass @options.class
    @number = new Data.Number {range:[-100,100],reset: on, steps: [200]}
    @sel = new Data.Select {list:{px: "px", '%': "%", em: "em",}}
    @number.addEvent 'change', ((value) ->
      @value = value
      @fireEvent 'change', String(@value)+@sel.value
    ).bindWithEvent @
    @sel.addEvent 'change', ( ->
      @fireEvent 'change', String(@value)+@sel.value
    ).bindWithEvent @
    @base.adopt @number, @sel
  setValue: (value) ->
    if typeof value is 'string'
      match = value.match(/(-?\d*)(.*)/)
      value = match[1]
      unit = match[2]
      @sel.setValue unit
    @number.setValue value
  getValue: ->
    String(@value)+@sel.value
}
    
