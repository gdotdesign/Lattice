###
---

name: Data.Date

description: 

license: MIT-style license.

requires: [Data.Abstract, Core.Slot]

provides: Data.Date

...
###
Data.Date: new Class {
  Extends:Data.Abstract
  options:{
    class:GDotUI.Theme.Date.Slot.class
    format:GDotUI.Theme.Date.format
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @days: new Core.Slot()
    @month: new Core.Slot()
    @years: new Core.Slot()
    @years.addEvent 'change', ( (item) ->
      @date.setYear item.value
      @setValue()
    ).bindWithEvent this
    @month.addEvent 'change', ( (item) ->
      @date.setMonth item.value
      @setValue();
    ).bindWithEvent this
    @days.addEvent 'change', ( (item) ->
      @date.setDate item.value
      @setValue()
    ).bindWithEvent this
    this
  ready: ->
    i: 0
    while i < 30
      item: new Iterable.ListItem {title:i+1}
      item.value: i+1;
      @days.addItem item
      i++
    i: 0
    while i < 12
      item: new Iterable.ListItem {title:i+1}
      item.value: i
      @month.addItem item
      i++
    i: 1950
    while i < 2012
      item: new Iterable.ListItem {title:i}
      item.value: i;
      @years.addItem item
      i++
    @base.adopt @years, @month, @days
    @setValue new Date()
    @base.setStyle 'height', @days.base.getSize().y
    $$(@days.base,@month.base,@years.base).setStyles {'float':'left'}
    @parent()
  setValue: (date) ->
    if date?
      @date: date
    @update()
    @fireEvent 'change', @date.format(@options.format)
  update: ->
    cdays: @date.get 'lastdayofmonth'
    listlength: @days.list.items.length
    if cdays>listlength
      i: listlength+1
      while i<=cdays
        item=new Iterable.ListItem {title:i}
        item.value: i
        @days.addItem item
        i++
    else if cdays<listlength
      i: listlength
      while i>cdays
        @days.list.removeItem @days.list.items[i-1]
        i--
    @days.select @days.list.items[@date.getDate()-1]
    @month.select @month.list.items[@date.getMonth()]
    @years.select @years.list.getItemFromTitle(@date.getFullYear())
}