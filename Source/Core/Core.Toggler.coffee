###
---

name: Core.Toggler

description: iOs style checkboxes

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Controls, Interfaces.Enabled]

provides: Core.Toggler

...
###
Element.Properties.checked = {
  get: ->
    if @getChecked?
      @getChecked()
  set: (value) ->
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
    @base.addClass @options.class
    @base.setStyle 'position','relative'
    @onLabel = new Element 'div', {text:@options.onText, class:@options.onClass}
    @offLabel = new Element 'div', {text:@options.offText, class:@options.offClass}
    @separator = new Element 'div', {html: '&nbsp;', class:@options.sepClass}
    @base.adopt @onLabel, @separator, @offLabel
    @base.getChecked = ( ->
      @checked
      ).bind @
    @base.on = @on.bind @
    @base.off = @off.bind @
  ready: ->
    $$(@onLabel,@offLabel,@separator).setStyles {
      'position':'absolute'
      'top': 0
      'left': 0
    }
    @follow()
    if @checked
      @on()
    else
      @off()
    @base.addEvent 'click', ( ->
       console.log 'clicked'
       if @checked
        @off()
        @base.fireEvent 'change'
       else
        @on()
        @base.fireEvent 'change'
    ).bind @
    @parent()
  on: ->
    @checked = yes
    @onLabel.setStyle 'left', 0
    @follow()
  off: ->
    @checked = no
    @onLabel.setStyle 'left', -@onLabel.getSize().x
    @follow()
  follow: ->
    left = @onLabel.getStyle('left')
    @separator.setStyle 'left', Number(left[0..left.length-3])+@onLabel.getSize().x
    @offLabel.setStyle 'left',Number(left[0..left.length-3])+@onLabel.getSize().x + @separator.getSize().x
}
