###
---

name: Core.Abstract

description: Abstract base class for Core U.I. elements.

license: MIT-style license.

requires: [Interfaces.Mux, GDotUI, Interfaces.Reflow]

provides: Core.Abstract

...
###
#INK save nodedata to html file in a comment.

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
###
(->
  Element.implement {
    inTheDom: ->
      if @parentNode
        if @parentNode.tagName.toLowerCase() is "html"
          true
        else
          $(@parentNode).inTheDom
      else
        false
    grab: (el, where) ->
      Element::grab.call(arguments, @)
      el.fireEvent 'addedToDom'
      @
    inject: (el, where) ->
      console.log @parent
      Element::inject.call(arguments, @)
      @fireEvent 'addedToDom'
      @
    adopt: ->
      elements = Array.flatten(arguments)
      elements.each (el) ->
        el.fireEvent 'addedToDom'
      Element::adopt.call(arguments, @)
      @
      
  }
)()
###
Core.Abstract = new Class {
  Implements:[Events
              Options
              Interfaces.Mux
              Interfaces.Reflow]
  initialize: (options) ->
    @setOptions options
    @base = new Element 'div'
    @create()
    #@createTemp()
    #@base.addEvent 'addedToDom', @ready.bindWithEvent @
    @mux()
    @
  create: ->
  ready: ->
    #@base.removeEvents 'addedToDom'
  toElement: ->
    @base
}
