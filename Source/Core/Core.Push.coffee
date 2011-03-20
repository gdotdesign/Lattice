###
---

name: Core.Push

description: Basic button element.

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
        if @base.hasClass 'pushed' then true else false
    }
    label: {
      value: GDotUI.Theme.Push.defaultText
      setter: (value) ->
        @base.set 'text', value
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
