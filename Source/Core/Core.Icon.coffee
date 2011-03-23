###
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Controls 
  - Interfaces.Enabled

provides: Core.Icon

...
###
Core.Icon = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  Attributes: {
    image: {
      setter: (value) ->
        @base.setStyle 'background-image', 'url(' + value + ')'
        value
    }
    class: {
      value: GDotUI.Theme.Icon.class
    }
  }
  create: ->
    @base.addEvent 'click', ( ->
      if @enabled
        @fireEvent 'invoked', @
    ).bind @
}
