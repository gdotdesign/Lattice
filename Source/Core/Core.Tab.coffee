###
---

name: Core.Tab

description: Tab element for Core.Tabs.

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
    image: GDotUI.Theme.Icons.remove
    active: GDotUI.Theme.Global.active
    removeable: off
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @base.addEvent 'click', ( ->
      @fireEvent 'activate', this
    ).bindWithEvent this
    @label: new Element 'div', {text: @options.label}
    @icon: new Core.Icon {image: @options.image}
    @icon.addEvent 'invoked', ( (ic,e) ->
      e.stop()
      @fireEvent 'remove', this
    ).bindWithEvent this
    @base.adopt @label
    if @options.removeable
      @base.grab @icon
  activate: ->
    @base.addClass @options.active 
  deactivate: ->
    @base.removeClass @options.active
}