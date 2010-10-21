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
Element.implement {
  removeTransition: ->
    @store 'transition', @getStyle( '-webkit-transition-duration' )
    @setStyle '-webkit-transition-duration', '0'
  addTransition: ->
    @setStyle '-webkit-transition-duration', @retrieve( 'transition' )
    @eliminate 'transition'
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
    @base.store 'transition', @base.getStyle( '-webkit-transition-duration' )
    @base.setStyle '-webkit-transition-duration', '0'
    @mux()
    @
  create: ->
  ready: ->
    @base.removeEvents 'addedToDom'
    @base.setStyle '-webkit-transition-duration', @base.retrieve( 'transition' )
    @base.eliminate 'transition'
  toElement: ->
    @base
}
