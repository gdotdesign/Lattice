###
---

name: Core.Push

description: Toggle button 'push' element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Enabled, GDotUI]

provides: Core.Push

...
###
Core.Push = new Class {
  Extends: Core.Abstract
  Implements: [Interfaces.Size, Interfaces.Enabled]
  Attributes: {
    state: {
      getter: ->
        @base.hasClass 'pushed' 
    }
    label: {
      value: GDotUI.Theme.Push.label
      setter: (value) ->
        @base.set 'text', value
        value
    }
    class: {
      value: GDotUI.Theme.Push.class
    }
  }
  initialize: (options) ->
    @parent options 
  on: ->
    @base.addClass 'pushed'
  off: ->
    @base.removeClass 'pushed'
  create: ->
    @base.addEvent 'click', ( ->
      if @enabled
        @base.toggleClass 'pushed'
      ).bind @  
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [@, e]
      ).bind @
}
