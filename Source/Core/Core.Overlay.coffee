###
---

name: Core.Overlay

description: Overlay for modal dialogs and stuff.

license: MIT-style license.

requires: [Core.Abstract, GDotUI]

provides: Core.Overlay

...
###
Core.Overlay = new Class {
  Extends: Core.Abstract
  Attributes: {
    class: {
      value: GDotUI.Theme.Overlay.class
    }
  }
  initialize: (options) ->
    @parent options 
  create: ->
    @base.setStyles {
      position:"fixed"
      top:0
      left:0
      right:0
      bottom:0
      opacity:0
      }
    @base.addEventListener 'webkitTransitionEnd', ((e) ->
      if e.propertyName == "opacity" and @base.getStyle('opacity') == 0
        @base.setStyle 'visiblity', 'hidden'
      ).bindWithEvent @
  hide: ->
    @base.setStyle 'opacity', 0
  show: ->
    @base.setStyles {
      visiblity: 'visible'
      opacity: 1
    }
}
