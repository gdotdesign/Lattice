###
---

name: Core.Select

description: Color data element. ( color picker )

license: MIT-style license.

requires: [Core.Abstract, GDotUI, Interfaces.Controls, Interfaces.Enabled, Interfaces.Children, Iterable.List]

provides: Core.Select

...
###
Prompt = new Class {
  Extends:Core.Abstract
  Delegates: {
    picker: ['justShow','hide','justAttach']
  }
  initialize: (options) ->
    @parent options
  create: ->
    @label = new Element 'div', {text:'addStuff'}
    @input = new Element 'input',{type:'text'}
    @button = new Element 'input', {type:'button'}
    @base.adopt @label,@input,@button;
    @picker = new Core.Picker();
    @picker.setContent @base
}
Core.Select = new Class {
  Extends:Core.Abstract
  Implements:[ Interfaces.Controls, Interfaces.Enabled]
  Attributes: {
    size: {
      setter: (value) ->
        @options.size = value
        @update()
    }
  }
  options: {
    width: 200
    class: 'select'
    default: ''
    editable: true
  }
  initialize: (options) ->
    @parent options
  getValue: ->
    li = @list.get('selected')
    if li?
      li.options.title
  setValue: (value) ->
    @list.select @list.getItemFromTitle(value)
  update: ->
    if @options.size?
      @size = @options.size
    @base.setStyle 'width', if @size < @minSize then @minSize else @size
    @list.base.setStyle 'width', if @size < @minSize then @minSize else @size
  create: ->
    @size = Number.from getCSS("/\\.#{@options.class}$/",'width')
    @minSize = Number.from getCSS("/\\.#{@options.class}$/",'min-width')
    @base.addClass @options.class
    @base.setStyle 'position', 'relative'
    @text = new Element('div.text', {text: @options.default or ''})
    @text.setStyles {
      position: 'absolute'
      top: 0
      left: 0
      right: 0
      bottom: 0
      'z-index': 0
      overflow: 'hidden'
    }
    if @options.editable
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
          @text.set 'text', @options.default or ''
      ).bind @
      @addIcon.addEvent 'invoked',( (el,e)->
        e.stop()
        if @enabled
          @prompt.justShow()
        #a = window.prompt('something')
        #if a
        #  item = new Iterable.ListItem {title:a,removeable:false,draggable:false}
        #  @addItem item
      ).bind @
      @base.adopt  @removeIcon, @addIcon
    @picker = new Core.Picker({offset:0})
    @picker.attachedTo = @base
    @base.addEvent 'click', ( (e) ->
      if @enabled
        @picker.show e
    ).bind @
    @list = new Iterable.List({class:'select-list'})
    @picker.setContent @list.base
    @base.adopt @text
    
    @prompt = new Prompt();
    @prompt.justAttach @base
    @list.addEvent 'select', ( (item,e)->
      if e?
        e.stop()
      @text.set 'text', item.options.title
      @fireEvent 'change', item.options.title
      @picker.forceHide()
    ).bind @
    @update();
    
  addItem: (item) ->
    item.base.set 'class', 'select-item'
    @list.addItem item
  removeItem: (item) ->
    @list.removeItem item
}
