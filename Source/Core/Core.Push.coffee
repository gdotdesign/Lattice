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
  Implements:[
    Interfaces.Enabled
  ]
  options:{
    text: GDotUI.Theme.Push.defaultText
    class: GDotUI.Theme.Push.class
  }
  initialize: (options) ->
    @parent options 
  on: ->
    @base.addClass 'pushed'
  off: ->
    @base.removeClass 'pushed'
  getState: ->
    if @base.hasClass 'pushed' then true else false
  create: ->
    @width = Number.from getCSS("/\\.#{@options.class}$/",'width')
    @base.addClass(@options.class).set 'text', @options.text
    @base.addEvent 'click', ( ->
      if @enabled
        @base.toggleClass 'pushed'
      ).bind @  
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [@, e]
      ).bind @
}
