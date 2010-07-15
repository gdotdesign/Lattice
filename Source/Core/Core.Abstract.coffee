###
---

name: Core.Abstract

description: 

license: MIT-style license.

requires: [Interfaces.Enabled, Interfaces.Controls]

provides: Core.Abstract

...
###
Core.Abstract: new Class {
  Implements:[Events
              Options
              Interfaces.Mux]
  initialize: (options) ->
    @setOptions options
    @base: new Element 'div'
    @create()
    fn: @ready.bindWithEvent this
    @base.store 'fn', fn
    @base.addEventListener 'DOMNodeInsertedIntoDocument', fn, off
    @mux()
    this
  create: ->
  ready: ->
    @base.removeEventListener 'DOMNodeInsertedIntoDocument', @base.retrieve('fn'), off
    @base.eliminate 'fn'
    this
}
