###
---

name: Data.Unit

description: Color data element. ( color picker )

license: MIT-style license.

requires: [Data.Abstract, GDotUI, Data.Select, Data.Number]

provides: Data.Unit

...
###
UnitList = {
  px: "px"
  '%': "%"
  em: "em"
  ex:"ex"
  gd:"gd"
  rem:"rem"
  vw:"vw"
  vh:"vh"
  vm:"vm"
  ch:"ch"
  "in":"in"
  mm:"mm"
  pt:"pt"
  pc:"pc"
  cm:"cm"
  deg:"deg"
  grad:"grad"
  rad:"rad"
  turn:"turn"
  s:"s"
  ms:"ms"
  Hz:"Hz"
  kHz:"kHz"
  }
Data.Unit = new Class {
  Extends:Data.Abstract
  Implements: Interfaces.Size
  Attributes: {
    class: {
      value: GDotUI.Theme.Unit.class
    }
  }
  initialize: (options) ->
    @parent options
  update: ->
    @number.set 'size', @size-@sel.get('size')
  create: ->
    @value = 0
    @selectSize = 80
    @number = new Data.Number {range:[-50,50],reset: on, steps: [100]}
    @sel = new Data.Select({size: 80})
    Object.each UnitList,((item) ->
      @sel.addItem new Iterable.ListItem({label:item,removeable:false,draggable:false})
    ).bind @
    @number.addEvent 'change', ((value) ->
      @value = value
      @fireEvent 'change', String(@value)+@sel.getValue()
    ).bindWithEvent @
    @sel.setValue 'px'
    @sel.addEvent 'change', ( ->
      @fireEvent 'change', String(@value)+@sel.getValue()
    ).bindWithEvent @
    @base.adopt @number, @sel
    @update()
  setValue: (value) ->
    if typeof value is 'string'
      match = value.match(/(-?\d*)(.*)/)
      value = match[1]
      unit = match[2]
      @sel.setValue unit
      @number.set value
  getValue: ->
    String(@value)+@sel.value
}
    
