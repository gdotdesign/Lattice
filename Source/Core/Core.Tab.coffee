###
---

name: Core.Tab

description: 

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.Tab

...
###
Core.Tab: new Class {
  Extends: Core.Abstract
  options:{
    class: GDotUI.Theme.Tab.class
    label: ''
  }
  initialize: (options) ->
    @parent options
    this
  create: ->
    @base.addClass @options.class
    @base.addEvent 'click', ( ->
      @fireEvent 'activate', this
    ).bindWithEvent this
    @label: new Element 'div', {text:@options.label}
    @icon: new Core.Icon {image:image:GDotUI.Theme.Icons.remove}
    @icon.addEvent 'invoked', ( (ic,e) ->
      e.stop()
      @fireEvent 'remove', this
    ).bindWithEvent this
    @base.adopt @label,@icon
  activate: ->
    @base.addClass 'active'
  deactivate: ->
    @base.removeClass 'active'
}