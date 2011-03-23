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
  Attributes: {
    class: {
      value: GDotUI.Theme.Date.DateTime.class
    }
    value: {
      value: new Date()
      setter: (value) ->
        @value = value
        @updateSlots()
        value
        
    }
  }
  options:{
    yearFrom: GDotUI.Theme.Date.yearFrom
  }
  create: ->
    @days = new Core.Slot()
    @month = new Core.Slot()
    @years = new Core.Slot()
    @hours = new Core.Slot()
    @minutes = new Core.Slot()
    @populate()
    @addEvents()
    @
  populate: ->
    i = 0
    while i < 24
      item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
      item.value = i
      @hours.addItem item
      i++
    i = 0
    while i < 60
      item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
      item.value = i
      @minutes.addItem item
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
  update: ->
    @fireEvent 'change', @value
  addEvents: ->
    @hours.addEvent 'change', ( (item) ->
      @value.set 'hours', item.value
      @update()
    ).bind @
    @minutes.addEvent 'change', ( (item) ->
      @value.set 'minutes', item.value
      @update()
    ).bind @
    @years.addEvent 'change', ( (item) ->
      @value.set 'year', item.value
      @update()
    ).bind @
    @month.addEvent 'change', ( (item) ->
      @value.set 'month', item.value
      @update()
    ).bind @
    @days.addEvent 'change', ( (item) ->
      @value.set 'date', item.value
      @update()
    ).bind @
    i = 0
  ready: ->
    @adoptChildren @years, @month, @days, @hours, @minutes
  updateSlots: ->
    cdays = @value.get 'lastdayofmonth'
    console.log @value.getDate(), 'hey',@value.get('hours')
    listlength = @days.list.items.length
    if cdays > listlength
      i = listlength+1
      while i <= cdays
        item=new Iterable.ListItem {label:i}
        item.value = i
        @days.addItem item
        i++
    else if cdays < listlength
      i = listlength
      while i > cdays
        @days.list.removeItem @days.list.items[i-1]
        i--
    @days.list.set 'selected', @days.list.items[@value.get('date')-1]
    @month.list.set 'selected', @month.list.items[@value.get('month')]
    @years.list.set 'selected', @years.list.getItemFromTitle(@value.get('year'))
    @hours.list.set 'selected', @hours.list.items[@value.get('hours')]
    @minutes.list.set 'selected', @minutes.list.items[@value.get('minutes')]
}
