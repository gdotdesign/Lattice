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
        @options.image = value
        @update()
    }
  }
  options:{
    image: null
    class: GDotUI.Theme.Icon.class
  }
  initialize: (options) ->
    @parent options
  update: ->
    if @options.image?
      @base.setStyle 'background-image', 'url(' + @options.image + ')'
  create: ->
    @base.addClass @options.class
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [@, e]
    ).bindWithEvent @
    @update()
}
