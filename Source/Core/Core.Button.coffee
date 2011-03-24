###
---

name: Core.Button

description: Basic button element.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled
  - Interfaces.Size

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
  create: ->
    @base.addEvent 'click', ((e)->
      if @enabled
        @fireEvent 'invoked', [@, e]
    ).bind @
}
