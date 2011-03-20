###
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, Interfaces.Enabled, GDotUI]

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
  initialize: (options) ->
    @parent options
  create: ->
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [@, e]
    ).bind @
}
