###
---

name: Element.Extras

description: Extra functions and monkeypatches for moootols Element.

license: MIT-style license.

provides: Element.Extras

...
###
(->
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
      document.id(el).fireEvent 'addedToDom'
      @
      
    inject: (el, where) ->
      @oldInject.attempt arguments, @
      @fireEvent 'addedToDom'
      @
      
    adopt: ->
      @oldAdopt.attempt arguments, @
      elements = Array.flatten(arguments)
      elements.each (el) ->
        document.id(el).fireEvent 'addedToDom'
      @
  }
)()
