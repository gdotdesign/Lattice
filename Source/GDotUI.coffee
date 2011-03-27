###
---

name: GDotUI

description: G.UI

license: MIT-style license.

provides: GDotUI

requires: [Class.Delegates, Element.Extras]

...
###
Interfaces = {}
Layout = {}
Core = {}
Data = {}
Iterable = {}
Pickers = {}
Forms = {}
Dialog = {}

if !GDotUI?
  GDotUI = {}

GDotUI.Config ={
    tipZindex: 100
    floatZindex: 0
    cookieDuration: 7*1000
}
GDotUI.selectors = ( ->
  selectors = {}
  Array.from(document.styleSheets).each (stylesheet) ->
    try 
      if stylesheet.cssRules?
        Array.from(stylesheet.cssRules).each (rule) ->
          selectors[rule.selectorText] = {}
          Array.from(rule.style).each (style) ->
            selectors[rule.selectorText][style] = rule.style.getPropertyValue(style)
  selectors
)()
