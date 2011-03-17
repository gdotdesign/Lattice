###
---

name: Core.Button

description: Basic button element.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Enabled, Interfaces.Controls, GDotUI]

provides: Core.Button

...
###
Core.Button = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  Attributes: {
    label: {
      setter: (value) ->
        @options.label = value
        @update()
    }
  }
  options:{
    label: GDotUI.Theme.Button.label
    class: GDotUI.Theme.Button.class
  }
  initialize: (options) ->
    @parent options 
  update: ->
    @base.set 'value', @options.label
  create: ->
    delete @base
    @base = new Element 'input', {type:'button'}
    @base.addClass @options.class
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [@, e]
      ).bind @
    @update()
}
