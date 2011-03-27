###
---

name: Core.Abstract

description: Abstract base class for Core U.I. elements.

license: MIT-style license.

requires: 
  - Class.Attributes
  - Element.Extras
  - GDotUI
  - Interfaces.Mux

provides: Core.Abstract

...
###

#INK save nodedata to html file in a comment.
# move this somewhere else

Core.Abstract = new Class {
  Implements:[Events
              Interfaces.Mux]
  Attributes: {
    class: {
      setter: (value, old) ->
        value = String.from value
        @base.removeClass old
        @base.addClass value
        value
    }
  }
  initialize: (options) ->
    @base = new Element 'div'
    @base.addEvent 'addedToDom', @ready.bind @
    @mux()
    @create()
    @setAttributes options
    @
  create: ->
  update: ->
  ready: ->
    @base.removeEvents 'addedToDom'
  toElement: ->
    @base
}
