###
---

name: Data.Date

description: Date picker element with Core.Slot-s

license: MIT-style license.

requires: [Data.Abstract, Core.Slot, GDotUI]

provides: Data.Date

...
###
Data.Date = new Class {
  Extends: Data.Abstract
  options:{
    class: GDotUI.Theme.Date.class
    format: GDotUI.Theme.Date.format
    yearFrom: GDotUI.Theme.Date.yearFrom
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @days = new Core.Slot()
    @month = new Core.Slot()
    @years = new Core.Slot()
    @years.addEvent 'change', ( (item) ->
      @date.setYear item.value
      @setValue()
    ).bindWithEvent @
    @month.addEvent 'change', ( (item) ->
      @date.setMonth item.value
      @setValue()
    ).bindWithEvent @
    @days.addEvent 'change', ( (item) ->
      @date.setDate item.value
      @setValue()
    ).bindWithEvent @
    i = 0
    while i < 30
      item = new Iterable.ListItem {label:i+1,removeable:false}
      item.value = i+1
      @days.addItem item
      i++
    i = 0
    while i < 12
      item = new Iterable.ListItem {label:i+1,removeable:false}
      item.value = i
      @month.addItem item
      i++
    i = @options.yearFrom
    while i <= new Date().getFullYear()
      item = new Iterable.ListItem {label:i,removeable:false}
      item.value = i
      @years.addItem item
      i++
    @base.adopt @years, @month, @days
  ready: ->
    if not @date?
      @setValue new Date()
  getValue: ->
    @date
  setValue: (date) ->
    if date?
      @date = date
    @update()
    @fireEvent 'change', @date
  update: ->
    cdays = @date.get 'lastdayofmonth'
    listlength = @days.list.items.length
    if cdays > listlength
      i = listlength+1
      while i <= cdays
        item=new Iterable.ListItem {title:i}
        item.value = i
        @days.addItem item
        i++
    else if cdays < listlength
      i = listlength
      while i > cdays
        @days.list.removeItem @days.list.items[i-1]
        i--
    @days.list.set 'selected', @days.list.items[@date.getDate()-1]
    @month.list.set 'selected', @month.list.items[@date.getMonth()]
    @years.list.set 'selected', @years.list.getItemFromTitle(@date.getFullYear())
}
