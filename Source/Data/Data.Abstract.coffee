###
---

name: Data.Abstract

description: Abstract base class for data elements.

license: MIT-style license.

requires: [GDotUI]

provides: Data.Abstract

...
###
Data.Abstract = new Class {
  Implements:[Events
              Options
              Interfaces.Reflow]
  options:{}
  initialize: (options) ->
    @setOptions options
    @base = new Element 'div'
    @createTemp()
    #@base.addEvent 'addedToDom', @pollReflow.bindWithEvent @
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
