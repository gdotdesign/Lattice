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
        @image = value
    }
    class: {
      value: GDotUI.Theme.Icon.class
    }
  }
  initialize: (options) ->
    @parent options
  update: ->
    if @image?
      @base.setStyle 'background-image', 'url(' + @image + ')'
  create: ->
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [@, e]
    ).bindWithEvent @
}
