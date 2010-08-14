###
---

name: Data.Unit

description: Color data element. ( color picker )

license: MIT-style license.

requires: Data.Abstract

provides: Data.Unit

...
###
UnitTable = {
  "px":{
    range:[-50,50]
    steps:[100]
  }
  "%":{
    range:[-50,50]
    steps:[100]
  }
  "em":{
    range:[-5,5]
    steps:[100]
  }
  "s":{
    range:[-10,10]
    steps:[100]
  }
  "default":{
    range:[-50,50]
    steps:[100]
  }
}
Data.Unit: new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Unit.class
  }
  initialize: (options) ->
    @parent(options)
  create: ->
    @value = 0
    @base.addClass @options.class
    @number = new Data.Number {range:[-50,50],reset: on, steps: [100]}
    @sel = new Data.Select {list:{px: "px"
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
                                  }}
    @number.addEvent 'change', ((value) ->
      @value = value
      @fireEvent 'change', String(@value)+@sel.value
    ).bindWithEvent @
    @sel.setValue 'px'
    @sel.addEvent 'change', ( ->
      #data = UnitTable[@sel.value] || UnitTable['default']
      #console.log data
      #@number.options.steps = data.steps
      #@number.options.range = data.range
      #@number.setValue @value
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
    
