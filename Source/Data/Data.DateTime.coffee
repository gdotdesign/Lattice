###
---

name: Data.DateTime

description:  Date & Time picker element with Core.Slot-s

license: MIT-style license.

requires: [Data.Abstract, GDotUI, Core.Slot, Iterable.ListItem]

provides: Data.DateTime

...
###
Data.DateTime = new Class {
  Extends:Data.Abstract
  Implements: [Interfaces.Enabled,Interfaces.Children]
  options:{
    class: GDotUI.Theme.Date.DateTime.class
    format: GDotUI.Theme.Date.DateTime.format
    yearFrom: GDotUI.Theme.Date.yearFrom
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @days = new Core.Slot()
    @month = new Core.Slot()
    @years = new Core.Slot()
    @hourList = new Core.Slot()
    @minuteList = new Core.Slot()
    @date = new Date();
    @populate()
    @adoptChildren @years, @month, @days, @hourList, @minuteList
    @addEvents()
    @
  populate: ->
    i = 0
    while i < 24
      item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
      item.value = i
      @hourList.addItem item
      i++
    i = 0
    while i < 60
      item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
      item.value = i
      @minuteList.addItem item
      i++
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
  addEvents: ->
    @hourList.addEvent 'change', ( (item) ->
      @date.setHours item.value
      @setValue()
    ).bindWithEvent @
    @minuteList.addEvent 'change', ( (item) ->
      @date.setMinutes item.value
      @setValue()
    ).bindWithEvent @
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
  ready: ->
    @setValue()
    @parent()
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
  getValue: ->
    @date
  setValue: (date) ->
    if date?
      @date = date
    @days.select @days.list.items[@date.getDate()-1]
    @update()
    @month.select @month.list.items[@date.getMonth()]
    @years.select @years.list.getItemFromTitle(@date.getFullYear())
    @hourList.select @hourList.list.items[@date.getHours()]
    @minuteList.select @minuteList.list.items[@date.getMinutes()]
    @fireEvent 'change', @date
}
