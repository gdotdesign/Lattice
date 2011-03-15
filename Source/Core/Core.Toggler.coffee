###
---

name: Core.Toggler

description: iOs style checkboxes

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, Interfaces.Enabled, GDotUI]

provides: Core.Toggler

...
###
Element.Properties.checked = {
  get: ->
    if @getChecked?
      @getChecked()
  set: (value) ->
    @setAttribute 'checked', value
    if @on? and @off?
      if value
        @on()
      else
        @off()
}

Core.Toggler = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  options:{
    class: GDotUI.Theme.Toggler.class
    onClass: GDotUI.Theme.Toggler.onClass
    offClass: GDotUI.Theme.Toggler.offClass
    sepClass: GDotUI.Theme.Toggler.separatorClass
    onText: GDotUI.Theme.Toggler.onText
    offText: GDotUI.Theme.Toggler.offText
  }
  initialize: (options) ->
    @checked = yes
    @parent options
  create: ->
    @width = @options.width or Number.from getCSS("/\\.#{@options.onClass}$/",'width')
    @base.addClass @options.class
    @base.setStyle 'position','relative'
    @onLabel = new Element 'div', {text:@options.onText, class:@options.onClass}
    @onLabel.removeTransition()
    @offLabel = new Element 'div', {text:@options.offText, class:@options.offClass}
    @offLabel.removeTransition()
    @separator = new Element 'div', {html: '&nbsp;', class:@options.sepClass}
    @separator.removeTransition()
    @base.adopt @onLabel, @offLabel, @separator
    @base.getChecked = ( ->
      @checked
      ).bind @
    @base.on = @on.bind @
    @base.off = @off.bind @
    $$(@onLabel,@offLabel,@separator).setStyles {
      'position':'absolute'
      'top': 0
      'left': 0
    }
    if @options.width
      $$(@onLabel,@offLabel,@separator).setStyles {
        width: @width
      }
      @base.setStyle 'width', @width*2
    @offLabel.setStyle 'left', @width
    if @checked
      @on()
    else
      @off()
    @base.addEvent 'click', ( ->
       if @enabled
         if @checked
          @off()
          @base.fireEvent 'change'
         else
          @on()
          @base.fireEvent 'change'
    ).bind @
    @onLabel.addTransition()
    @offLabel.addTransition()
    @separator.addTransition()
    @parent()
  on: ->
    @checked = yes
    @separator.setStyle 'left', @width
  off: ->
    @checked = no
    @separator.setStyle 'left', 0
}
