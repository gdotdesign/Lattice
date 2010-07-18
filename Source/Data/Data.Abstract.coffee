###
---

name: Data.Abstract

description: "Abstract" base class for data elements.

license: MIT-style license.

requires: 

provides: Data.Abstract

...
###
Data.Abstract: new Class {
  Implements:[Events
              Options]
  options:{}
  initialize: (options) ->
    @setOptions options
    @base: new Element 'div'
    fn: @ready.bindWithEvent this
    @base.store 'fn', fn
    @base.addEventListener 'DOMNodeInsertedIntoDocument', fn, no
    @create()
    this
  create: ->
  ready: ->
    @base.removeEventListener 'DOMNodeInsertedIntoDocument', @base.retrieve('fn'), no
    @base.eliminate 'fn'
  toElement: ->
    @base
  setValue: ->
  getValue: ->
}
