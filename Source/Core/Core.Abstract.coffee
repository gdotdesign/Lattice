###
---

name: Core.Abstract

description: Abstract base class for Core U.I. elements.

license: MIT-style license.

requires: [Interfaces.Mux, GDotUI, Element.Extras, Class.Extras]

provides: Core.Abstract

...
###

#INK save nodedata to html file in a comment.
# move this somewhere else
getCSS = (selector, property) ->
  #selector = "/\\.#{@get('class')}$/"
  ret = null
  checkStyleSheet = (stylesheet) ->
    try
      if stylesheet.cssRules?
        $A(stylesheet.cssRules).each (rule) ->
          if rule.styleSheet?
            checkStyleSheet(rule.styleSheet)
          if rule.selectorText?
            if rule.selectorText.test(eval(selector))
              ret = rule.style.getPropertyValue(property)
    catch error
      console.log error
  $A(document.styleSheets).each (stylesheet) ->
    checkStyleSheet(stylesheet)
  ret

Core.Abstract = new Class {
  Implements:[Events
              Options
              Interfaces.Mux]
  initialize: (options) ->
    @setOptions options
    @base = new Element 'div'
    @base.addEvent 'addedToDom', @ready.bindWithEvent @
    @create()
    @mux()
    @
  create: ->
  ready: ->
    @base.removeEvents 'addedToDom'
  toElement: ->
    @base
}
