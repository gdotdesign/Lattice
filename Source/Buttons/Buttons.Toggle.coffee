###
---

name: Buttons.Toggle

description: Toggle button element.

license: MIT-style license.

requires: 
  - Buttons.Abstract

provides: Buttons.Toggle

...
###
Buttons.Toggle = new Class {
  Extends: Buttons.Abstract
  Attributes: {
    state: {
      value: false
      setter: (value, old) ->
        if value
          @base.addClass 'pushed'
        else
          @base.removeClass 'pushed'
        value
      getter: ->
        @base.hasClass 'pushed' 
    }
    class: {
      value: Lattice.buildClass 'button-toggle'
    }
  }
  create: ->
    @addEvent 'stateChange', ->
      @fireEvent 'invoked', [@,@state]
    @base.addEvent 'click', =>
      if @enabled
        @set 'state', if @state then false else true
}
