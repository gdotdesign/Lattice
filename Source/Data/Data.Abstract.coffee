###
---

name: Data.Abstract

description: Abstract base class for data elements.

license: MIT-style license.

requires: [GDotUI,Interfaces.Mux]

provides: Data.Abstract

...
###
Data.Abstract = new Class {
  Implements:[Events
              Options
              Interfaces.Mux]
  options:{}
  initialize: (options) ->
    @setOptions options
    @base = new Element 'div'
    @base.addEvent 'addedToDom', @ready.bindWithEvent @
    @mux()
    @create()
    @
  create: ->
  ready: ->
  toElement: ->
    @base
  setValue: ->
  getValue: ->
    @value
}
