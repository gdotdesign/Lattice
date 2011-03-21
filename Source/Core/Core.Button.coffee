###
---

name: Core.Button

description: Basic button element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Enabled, Interfaces.Controls, GDotUI, Interfaces.Size]

provides: Core.Button

...
###
Core.Button = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
    Interfaces.Size
  ]
  Attributes: {
    label: {
      value: GDotUI.Theme.Button.label
      setter: (value) ->
        @base.set 'text', value
        value
    }
    class: {
      value: GDotUI.Theme.Button.class
    }
  }
  initialize: (attributes) ->
    @parent attributes 
  create: ->
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [@, e]
      ).bind @
}
