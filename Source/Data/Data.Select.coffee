###
---

name: Data.Select

description: Select Element

license: MIT-style license.

requires: [Core.Abstract, GDotUI, Interfaces.Controls, Interfaces.Enabled, Interfaces.Children, Iterable.List, Dialog.Prompt]

provides: [Data.Select]

...
###
Data.Select = new Class {
  Extends:Core.Abstract
  Implements:[ Interfaces.Controls, Interfaces.Enabled, Interfaces.Size, Interfaces.Children]
  Attributes: {
    class: {
      value: 'select'
    }
    default: {
      value: ''
      setter: (value, old) ->
        if @text.get('text') is (old or '')
          @text.set 'text', value
        value
    }
    selected: {
      getter: ->
        @list.get 'selected'
    }
    editable: {
      value: yes
      setter: (value) ->
        if value
          @adoptChildren  @removeIcon, @addIcon
        else
          document.id(@removeIcon).dispose()
          document.id(@addIcon).dispose()
        value
          
    }
  }
  getValue: ->
    li = @list.get('selected')
    if li?
      li.label
  setValue: (value) ->
    @list.set 'selected', @list.getItemFromTitle(value)
  update: ->
    @list.base.setStyle 'width', if @size < @minSize then @minSize else @size
  create: ->
    @base.setStyle 'position', 'relative'
    @text = new Element('div.text')
    @text.setStyles {
      position: 'absolute'
      top: 0
      left: 0
      right: 0
      bottom: 0
      'z-index': 0
      overflow: 'hidden'
    }
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
    @removeIcon.addEvent 'invoked',( (el,e)->
      e.stop()
      if @enabled
        @removeItem @list.get('selected')
        @text.set 'text', @default or ''
    ).bind @
    @addIcon.addEvent 'invoked',( (el,e)->
      e.stop()
      if @enabled
        @prompt.show()
    ).bind @
    
    @picker = new Core.Picker({offset:0,position:{x:'center',y:'bottom'}})
    @picker.attach @base
    @list = new Iterable.List({class:'select-list'})
    @picker.set 'content', @list
    @base.adopt @text
    
    @prompt = new Dialog.Prompt();
    @prompt.set 'label', 'Add item:'
    @prompt.attach @base, false
    @prompt.addEvent 'invoked', ((value) ->
      if value
        item = new Iterable.ListItem {label:value,removeable:false,draggable:false}
        @addItem item
        @list.set 'selected', item
      @prompt.hide null, yes
    ).bind @
    
    @list.addEvent 'selectedChange', ( ->
      item = @list.selected
      @text.set 'text', item.label
      @fireEvent 'change', item.label
      @picker.hide null, yes
    ).bind @
    @update()
    
  addItem: (item) ->
    item.base.set 'class', 'select-item'
    @list.addItem item
  removeItem: (item) ->
    @list.removeItem item
}
