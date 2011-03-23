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
  Attributes: {
    class: {
      value: GDotUI.Theme.Date.class
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
    @populate()
    @addEvents()
  addEvents: ->
    @years.addEvent 'change', ( (item) ->
      @value.set 'year', item.label
      @update()
    ).bind @
    @month.addEvent 'change', ( (item) ->
      @value.set 'month', item.label
      @update()
    ).bind @
    @days.addEvent 'change', ( (item) ->
      @value.set 'date', item.label
      @update()
    ).bind @
  populate: ->
    i = 0
    while i < 30
      item = new Iterable.ListItem {label:i+1,removeable:false}
      @days.addItem item
      i++
    i = 0
    while i < 12
      item = new Iterable.ListItem {label:i+1,removeable:false}
      @month.addItem item
      i++
    i = @options.yearFrom
    while i <= new Date().get('year')
      item = new Iterable.ListItem {label:i,removeable:false}
      @years.addItem item
      i++
  ready: ->
    @base.adopt @years, @month, @days
  update: ->
    @fireEvent 'change', @value
  updateSlots: ->
    cdays = @value.get 'lastdayofmonth'
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
}
