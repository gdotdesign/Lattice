###
---

name: Data.Abstract

description: "Abstract" base class for data elements.

license: MIT-style license.

provides: Data.Abstract

...
###
Data.Abstract = new Class {
  Implements:[Events
              Options]
  options:{}
  initialize: (options) ->
    @setOptions options
    @base = new Element 'div'
    @base.addEvent 'addedToDom', @ready.bindWithEvent @
    @create()
    @
  create: ->
  ready: ->
    @base.removeEvents 'addedToDom'
  toElement: ->
    @base
  setValue: ->
  getValue: ->
    @value
}
