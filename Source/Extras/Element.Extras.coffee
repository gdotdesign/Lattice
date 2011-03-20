###
---

name: Element.Extras

description: Extra functions and monkeypatches for moootols Element.

license: MIT-style license.

provides: Element.Extras

...
###
Element.Properties.checked = {
  get: ->
    if @getChecked?
      @getChecked()
  set: (value) ->
    @setAttribute 'checked', value
    if @on? and @off?
      if value
        @on()
      else
        @off()
}
(->
  Element.Events.outerClick = {
    base: 'mousedown'
    condition: (event) ->
      event.stopPropagation()
      off
    onAdd: (fn) ->
      window.addEvent 'click', fn
      window.addEvent 'outer', fn
    onRemove: (fn) ->
      window.removeEvent 'click', fn
      window.removeEvent 'outer', fn
  }
  Element.implement {
    oldGrab: Element::grab
    oldInject: Element::inject
    oldAdopt: Element::adopt
    
    removeTransition: ->
      @store 'transition', @getStyle( '-webkit-transition-duration' )
      @setStyle '-webkit-transition-duration', '0'
      
    addTransition: ->
      @setStyle '-webkit-transition-duration', @retrieve( 'transition' )
      @eliminate 'transition'
      
    inTheDom: ->
      if @parentNode
        if @parentNode.tagName.toLowerCase() is "html"
          true
        else
          $(@parentNode).inTheDom
      else
        false
        
    grab: (el, where) ->
      @oldGrab.attempt arguments, @
      e = document.id(el)
      if e.fireEvent?
        e.fireEvent 'addedToDom'
      @
      
    inject: (el, where) ->
      @oldInject.attempt arguments, @
      @fireEvent 'addedToDom'
      @
      
    adopt: ->
      @oldAdopt.attempt arguments, @
      elements = Array.flatten(arguments)
      elements.each (el) ->
        e = document.id(el)
        if e.fireEvent?
          document.id(el).fireEvent 'addedToDom'
      @
  }
)()
