###
---

name: Data.Abstract

description: Abstract base class for data elements.

license: MIT-style license.

requires: [GDotUI, Interfaces.Mux]

provides: Data.Abstract

...
###
Data.Abstract = new Class {
  Implements:[Events
              Interfaces.Mux]
  Attributes: {
    class: {
      setter: (value, old) ->
        @base.removeClass old
        @base.addClass value
        value
    }
  }
  initialize: (options) ->
    @base = new Element 'div'
    @base.addEvent 'addedToDom', @ready.bindWithEvent @
    @create()
    @mux()
    @setAttributes options
    @
  update: ->
  create: ->
  ready: ->
  toElement: ->
    @base
  setValue: ->
  getValue: ->
    @value
}
