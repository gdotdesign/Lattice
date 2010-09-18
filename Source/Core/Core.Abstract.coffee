###
---

name: Core.Abstract

description: "Abstract" base class for Core U.I. elements.

license: MIT-style license.

requires: [Interfaces.Mux]

provides: Core.Abstract

...
###
# Abstract class to be extended on.
# 
# Implements:
# 
# * Events
# * Options
# * Interfaces.Mux
Core.Abstract = new Class {
  Implements:[Events
              Options
              Interfaces.Mux]
  # ### Constructor
  # After setting the options, create the base object
  # which is a Html element, in this case a div.
  initialize: (options) ->
    @setOptions options
    @base = new Element 'div'
    # Call the create function which can be overriden.
    @create()
    # Bind the ready event because the MooTools 1.2 doesn't support addEvent for 'DOMNodeInsertedIntoDocument',
    # then store it so it can be removed later on, then add the event listener.
    fn = @ready.bindWithEvent @
    @base.store 'fn', fn
    @base.addEventListener 'DOMNodeInsertedIntoDocument', fn, no
    # This initializes the other interfaces.
    @mux()
    # Return itself.
    @
  # #### create()
  # This is an empty function, it has to be delacred so if any child class doesn't override it
  # it should still work.
  create: ->
  # #### ready()
  # This function runs when the event 'DOMNodeInsertedIntoDocument' fires. So when it runs the base element is fully
  # rendered and can be measured via Mootools getSize().
  ready: ->
    @base.removeEventListener 'DOMNodeInsertedIntoDocument', @base.retrieve('fn'), no
    @base.eliminate 'fn'
  # #### toElement()
  # This is just so it works with document.id, grab, adopt etc.
  toElement: ->
    @base
}
