###
---

name: Iterable.ListItem

description: 

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

...
###
Iterable.ListItem: new Class {
  Extends:Core.Abstract
  Implements: Interfaces.Draggable
  options:{
    class:GDotUI.Theme.ListItem.class
    title:''
    subtitle:''
    draggable: on
    ghost: on
    removeClasses: '.icon'
  }
  initialize: (options) ->
    @parent options
    @enabled: on
    this
  create: ->
    @base.addClass(@options.class).setStyle  'position','relative'
    @remove: new Core.Icon {image:GDotUI.Theme.Icons.remove}
    @handles: new Core.Icon {image:GDotUI.Theme.Icons.handleVertical}
    @handles.base.addClass 'list-handle'
    $$(@remove.base,@handles.base).setStyle 'position','absolute'
    @title: new Element('div').addClass(GDotUI.Theme.ListItem.title).set 'text', @options.title
    @subtitle: new Element('div').addClass(GDotUI.Theme.ListItem.subTitle).set 'text', @options.subtitle
    @base.adopt @title,@subtitle, @remove, @handles
    #Invoked
    @base.addEvent 'click', ( ->
      if @enabled
        @fireEvent 'invoked', this
     ).bindWithEvent this
     @base.addEvent 'dblclick', ( ->
       if @enabled
         if @editing
           @fireEvent 'edit', this
     ).bindWithEvent this
  toggleEdit: ->
    if @editing
      @remove.base.setStyle 'right', -@remove.base.getSize().x
      @handles.base.setStyle 'left', -@handles.base.getSize().x
      @base.setStyle 'padding-left', @base.retrieve('padding-left:old')
      @base.setStyle 'padding-right', @base.retrieve('padding-right:old')
      @editing: off
    else
      @remove.base.setStyle 'right',GDotUI.Theme.ListItem.iconOffset
      @handles.base.setStyle 'left',GDotUI.Theme.ListItem.iconOffset
      @base.store 'padding-left:old', @base.getStyle('padding-left')
      @base.store 'padding-right:old', @base.getStyle('padding-left')
      @base.setStyle 'padding-left', Number(@base.getStyle('padding-left').slice(0,-2))+@handles.base.getSize().x
      @base.setStyle 'padding-right', Number(@base.getStyle('padding-right').slice(0,-2))+@remove.base.getSize().x
      @editing: on
  ready: ->
    if not @editing
      handSize: @handles.base.getSize()
      remSize: @remove.base.getSize()
      baseSize: @base.getSize()
      @remove.base.setStyles {
        "right":-remSize.x
        "top":(baseSize.y-remSize.y)/2
        }
      @handles.base.setStyles {
        "left":-handSize.x,
        "top":(baseSize.y-handSize.y)/2
        }
      @parent()
}