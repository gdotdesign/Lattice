###
---

name: Core.Button

description: 

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Enabled, Interfaces.Controls]

provides: Core.Button

...
###
Core.Button: new Class {
  Extends:Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  options:{
    image: ''
    text: ''
    class: GDotUI.Theme.Button.class
  }
  initialize: (options) ->
    @parent(options)
    @enabled: on
    this
  create: ->
    delete @base
    @base: new Element 'button'
    @base.addClass(this.options['class']).set 'text', @options.text
    @icon: new Core.Icon {image:@options.image}
    @base.addEvent 'click', ((e) ->
      if @enabled
        @fireEvent 'invoked', [this, e]
      ).bindWithEvent this
  ready: ->
      @base.grab @icon
      @icon.base.setStyle 'float', 'left'
      @parent();
}