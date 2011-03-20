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
  Attributes: {
    state: {
      getter: ->
        if @base.hasClass 'pushed' then true else false
    }
    label: {
      setter: (value) ->
        @options.label = value
        @update()
    }
    size: {
      setter: (value) ->
        @options.size = value
        @update()
    }
  }
  Implements:[
    Interfaces.Enabled
  ]
  options:{
    label: GDotUI.Theme.Push.defaultText
    class: GDotUI.Theme.Push.class
  }
  initialize: (options) ->
    @parent options 
  on: ->
    @base.addClass 'pushed'
  off: ->
    @base.removeClass 'pushed'
  update: ->
    if @options.size?
      @size = @options.size
      @base.setStyle 'width', if @size < @minSize then @minSize else @size
  create: ->
    @size = Number.from getCSS("/\\.#{@options.class}$/",'width')
    @minSize = Number.from(getCSS("/\\.#{@options.class}$/",'min-width')) or 0
    @base.addClass(@options.class).set 'text', @options.label
    @base.addEvent 'click', ( ->
      if @enabled
        @base.toggleClass 'pushed'
      ).bind @  
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [@, e]
      ).bind @
    @update()
}
