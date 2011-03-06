###
---

name: Core.Abstract

description: "Abstract" base class for Core U.I. elements.

license: MIT-style license.

requires: [Interfaces.Mux]

provides: Core.Abstract

...
###
Element.NativeEvents['DOMNodeInsertedIntoDocument'] = 2
Element.Events['addedToDom'] = {
  base: 'DOMNodeInsertedIntoDocument'
}
Core.Abstract = new Class {
  Implements:[Events
              Options
              Interfaces.Mux]
  initialize: (options) ->
    @setOptions options
    @base = new Element 'div'
    @create()
    @base.addEvent 'addedToDom', @ready.bindWithEvent @
    @mux()
    @
  create: ->
  ready: ->
    @base.removeEvents 'addedToDom'
  toElement: ->
    @base
}
