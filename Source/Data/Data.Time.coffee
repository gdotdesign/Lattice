###
---

name: Data.Time

description: Time picker element with Core.Slot-s

license: MIT-style license.

requires: Data.Abstract

provides: Data.Time

...
###
Data.Time = new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Date.Time.class
    format: GDotUI.Theme.Date.Time.format
  }
  initilaize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @hourList = new Core.Slot()
    @minuteList = new Core.Slot()
    @hourList.addEvent 'change', ( (item) ->
      @time.setHours item.value
      @setValue()
    ).bindWithEvent @
    @minuteList.addEvent 'change', ( (item) ->
      @time.setMinutes item.value
      @setValue()
    ).bindWithEvent @
  getValue: ->
    @time.format @options.format
  setValue: (date) ->
    if date?
      @time = date
    @hourList.select @hourList.list.items[@time.getHours()]
    @minuteList.select @minuteList.list.items[@time.getMinutes()]
    @fireEvent 'change', @time.format(@options.format)
  ready: ->
    i = 0
    while i < 24
      item = new Iterable.ListItem {title:i}
      item.value = i
      @hourList.addItem item
      i++
    i = 0
    while i < 60
      item = new Iterable.ListItem {title: if i<10 then '0'+i else i}
      item.value = i
      @minuteList.addItem item
      i++
    @base.adopt @hourList, @minuteList
    @setValue new Date()
    @parent()
}
