###
---

name: Data.DateTime

description:  Date & Time picker element with Core.Slot-s

license: MIT-style license.

requires: [Data.Abstract, Data.Date, Data.Time, GDotUI]

provides: Data.DateTime

...
###
Data.DateTime = new Class {
  Extends:Data.Abstract
  options:{
    class: GDotUI.Theme.Date.DateTime.class
    format: GDotUI.Theme.Date.DateTime.format
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @datea = new Data.Date()
    @time = new Data.Time()
  ready: ->
    @base.adopt @datea, @time
    @setValue( @date or new Date())
    @datea.addEvent 'change',( ->
      @date.setYear @datea.date.getFullYear()
      @date.setMonth @datea.date.getMonth()
      @date.setDate @datea.date.getDate()
      @fireEvent 'change', @date
    ).bindWithEvent @
    @time.addEvent 'change',( ->
      @date.setHours @time.time.getHours()
      @date.setMinutes @time.time.getMinutes()
      @fireEvent 'change', @date
    ).bindWithEvent @
    @parent()
  getValue: ->
    @date.format(@options.format)
  setValue: (date) ->
    if date?
      @date = date
    @datea.setValue @date
    @time.setValue @date
    @fireEvent 'change', @date
}
