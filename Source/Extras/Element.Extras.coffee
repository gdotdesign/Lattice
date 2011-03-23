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
( ->
  oldPrototypeStart = Drag::start
  Drag.prototype.start = ->
    window.fireEvent 'outer'
    oldPrototypeStart.run arguments, @
)()
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
    oldPosition: Element::position
    position: (options) ->
      op = {
        relativeTo: document.body
        position: {x:'center',y:'center'}
      }
      options = Object.merge op, options
      winsize = window.getSize()
      winscroll = window.getScroll()
      asize = options.relativeTo.getSize()
      position = options.relativeTo.getPosition()
      size = @getSize()
      x = ''
      y = ''
      if options.position.x is 'auto' and options.position.y is 'auto'
        if (position.x+size.x+asize.x) > (winsize.x-winscroll.x) then x = 'left' else x = 'right'          
        if (position.y+size.y+asize.y) > (winsize.y-winscroll.y) then y = 'top' else y = 'bottom'
        if not ((position.y+size.y/2) > (winsize.y-winscroll.y)) and not ((position.y-size.y) < 0) then y = 'center'    
        options.position = {x:x,y:y}
      
      ofa = {}
                      
      switch options.position.x
        when 'center'
          if options.position.y isnt 'center'
            ofa.x = -size.x/2
        when 'left'
          ofa.x = -(options.offset+size.x)
        when 'right'
          ofa.x = options.offset
      switch options.position.y
        when 'center'
          if options.position.x isnt 'center'
            ofa.y = -size.y/2
        when 'top'
          ofa.y = -(options.offset+size.y)
        when 'bottom'
          ofa.y = options.offset
       options.offset = ofa
       @oldPosition.attempt options, @
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
