###
---

name: Core.Select

description: Color data element. ( color picker )

license: MIT-style license.

requires: [Core.Abstract, GDotUI, Interfaces.Controls, Interfaces.Enabled, Interfaces.Children, Iterable.List]

provides: Core.Select

...
###
Core.Select = new Class {
  Extends:Core.Abstract
  Implements:[ Interfaces.Controls, Interfaces.Enabled]
  options: {
    width: 200
    class: 'select'
  }
  initialize: (options) ->
    @parent options
  getValue: ->
    @list.get('selected').options.title
  setValue: (value) ->
    @list.select @list.getItemFromTitle(value)
  create: ->
    @base.addClass @options.class
    @base.setStyle 'position', 'relative'
    @text = new Element('div', {text: @options.default or ''})
    @text.setStyles {
      position: 'absolute'
      top: 0
      left: 0
      right: 0
      bottom: 0
      'z-index': 0
      overflow: 'hidden'
    }
    if @options.width?
      @size = @options.width
      @base.setStyle 'width', @size
    else
      @size = Number.from getCSS("/\\.#{@options.class}$/",'width')
    @addIcon = new Core.Icon()
    @addIcon.base.addClass 'add'
    @addIcon.base.set 'text', '+'
    @removeIcon = new Core.Icon()
    @removeIcon.base.set 'text', '-'
    @removeIcon.base.addClass 'remove'
    $$(@addIcon.base,@removeIcon.base).setStyles {
      'z-index': '1'
      'position': 'relative'
    }
    @picker = new Core.Picker()
    @picker.attach @base
    @list = new Iterable.List({class:'select-list'})
    @picker.setContent @list.base
    #@list.base.setStyle 'width', @size
    @base.adopt @text, @removeIcon, @addIcon
    @list.addEvent 'select', ( (item,e)->
      if e?
        e.stop()
      @text.set 'text', item.options.title
      @fireEvent 'change', item.options.title
      @picker.forceHide()
    ).bind @
    @removeIcon.addEvent 'invoked',( (el,e)->
      e.stop()
      @removeItem @list.get('selected')
      @text.set 'text', @options.default or ''
    ).bind @
    @addIcon.addEvent 'invoked',( (el,e)->
      e.stop()
      a = window.prompt('something')
      item = new Iterable.ListItem {title:a,removeable:false,draggable:false}
      @addItem item
    ).bind @
  addItem: (item) ->
    item.base.set 'class', 'select-item'
    @list.addItem item
  removeItem: (item) ->
    @list.removeItem item
}
