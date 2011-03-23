###
---

name: Data.Time

description: Time picker element with Core.Slot-s

license: MIT-style license.

requires: [Data.Abstract, GDotUI, Interfaces.Children]

provides: Data.Time

...
###
Data.Time = new Class {
  Extends:Data.Abstract
  Implements: [Interfaces.Enabled,Interfaces.Children]
  Attributes: {
    class: {
      value: GDotUI.Theme.Date.Time.class
    }
    value: {
      value: new Date()
      setter: (value) ->
        @value = value
        @updateSlots()
        value
        
    }
  }
  create: ->
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
  ready: ->
    @adoptChildren @hours, @minutes
  updateSlots: ->
    @hours.list.set 'selected', @hours.list.items[@value.get('hours')]
    @minutes.list.set 'selected', @minutes.list.items[@value.get('minutes')]
}
