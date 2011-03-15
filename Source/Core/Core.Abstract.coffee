###
---

name: Core.Abstract

description: Abstract base class for Core U.I. elements.

license: MIT-style license.

requires: [Interfaces.Mux, GDotUI, Interfaces.Reflow]

provides: Core.Abstract

...
###
Class.Mutators.Refactors = (refactors) ->
  Object.each(refactors, (item,name) ->
    origin = @prototype[name]
    if origin and origin.$origin then origin = origin.$origin
    origin.implement name, if typeof item is 'function' then ->
      old = @previous
      @previous = origin or ->
      value = item.apply @, arguments
      @previous = old
      value
    else item
  , @)
#INK save nodedata to html file in a comment.
Element.implement {
  removeTransition: ->
    @store 'transition', @getStyle( '-webkit-transition-duration' )
    @setStyle '-webkit-transition-duration', '0'
  addTransition: ->
    @setStyle '-webkit-transition-duration', @retrieve( 'transition' )
    @eliminate 'transition'
}
getCSS = (selector, property) ->
  #selector = "/\\.#{@get('class')}$/"
  ret = null
  checkStyleSheet = (stylesheet) ->
    if stylesheet.cssRules?
      $A(stylesheet.cssRules).each (rule) ->
        if rule.styleSheet?
          checkStyleSheet(rule.styleSheet)
        if rule.selectorText?
          if rule.selectorText.test(eval(selector))
            ret = rule.style.getPropertyValue(property)
  $A(document.styleSheets).each (stylesheet) ->
    checkStyleSheet(stylesheet)
  ret

(->
  Element.implement {
    oldGrab: Element::grab
    oldInject: Element::inject
    oldAdopt: Element::adopt
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
Core.Abstract = new Class {
  Implements:[Events
              Options
              Interfaces.Mux
              Interfaces.Reflow]
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
