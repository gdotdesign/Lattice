###
---

name: Core.Button

description: Basic button element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Enabled, Interfaces.Controls]

provides: Core.Button

...
###
Core.Button = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  options:{
    image: GDotUI.Theme.Button.defaultIcon
    text: GDotUI.Theme.Button.defaultText
    class: GDotUI.Theme.Button.class
  }
  initialize: (options) ->
    @parent options 
  create: ->
    delete @base
    @base = new Element 'button'
    @base.addClass(@options.class).set 'text', @options.text
    @icon = new Core.Icon {image: @options.image}
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [@, e]
      ).bindWithEvent @
  ready: ->
    @base.grab @icon
    @parent()
}
