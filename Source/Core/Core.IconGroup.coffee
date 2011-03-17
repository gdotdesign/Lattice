###
---

name: Core.IconGroup

description: Icon group with 5 types of layout.

license: MIT-style license.

requires: [Core.Abstract, GDotUI, Interfaces.Controls, Interfaces.Enabled, Interfaces.Children]

provides: Core.IconGroup

...
###
Core.IconGroup = new Class {
  Extends: Core.Abstract
  Implements: [Interfaces.Controls, Interfaces.Enabled, Interfaces.Children]
  Binds: ['delegate']
  Attributes: {
    mode: {
      setter: (value) ->
        @options.mode = value
        @update()
      validator: (value) ->
        if ['horizontal','vertical','circular','grid','linear'].indexOf(value) > -1 then true else false
    }
    spacing: {
      setter: (value) ->
        @options.spacing = value
        @update()
      validator: (value) ->
        if typeOf(value) is 'object'
          if value.x? and value.y? then yes else no
        else no
    }
    startAngle: {
      setter: (value) ->
        @options.startAngle = Number.from(value)
        @update()
      validator: (value) ->
        if (a = Number.from(value))?
          if a >= 0 and a <= 360 then yes else no
        else no
    }
    radius: {
      setter: (value) ->
        @options.radius = Number.from(value)
        @update()
      validator: (value) ->
        if (a = Number.from(value))? then yes else no
    }
    degree: {
      setter: (value) ->
        @options.degree = Number.from(value)
        @update()
      validator: (value) ->
        if (a = Number.from(value))?
          if a >= 0 and a <= 360 then yes else no
        else no
    }
    rows: {
      setter: (value) ->
        @options.rows = Number.from(value)
        @update()
      validator: (value) ->
        if (a = Number.from(value))?
          if a > 0 then yes else no
        else no
    }
    columns: {
      setter: (value) ->
        @options.columns = Number.from(value)
        @update()
      validator: (value) ->
        if (a = Number.from(value))?
          if a > 0 then yes else no
        else no
    }
  }
  options: {
    mode: "horizontal"
    spacing: {
      x: 0
      y: 0
    }
    startAngle: 0 #degree
    radius: 0 #degree
    degree: 360 #degree
    class: GDotUI.Theme.IconGroup.class
  }
  initialize: (options) ->
    @icons = []
    @parent options
  create: ->
    @base.setStyle 'position', 'relative'
    @base.addClass @options.class
  delegate: ->
    @fireEvent 'invoked', arguments
  addIcon: (icon) ->
    if @icons.indexOf icon is -1
      icon.addEvent 'invoked', @delegate
      @addChild icon
      @icons.push icon
      yes
    else no
  removeIcon: (icon) ->
    index = @icons.indexOf icon
    if index isnt -1
      icon.removeEvent 'invoked', @delegate
      icon.base.dispose()
      @icons.splice index, 1
      yes
    else no
  ready: ->
    @update()
  update: ->
    x = 0
    y = 0
    @size = {x:0, y:0}
    spacing = @options.spacing
    switch @options.mode
      when 'grid'
        if @options.rows? and @options.columns?
          if Number.from(@options.rows) < Number.from(@options.columns)
            @options.rows = null
          else
            @options.columns = null
        if @options.columns?
          columns = @options.columns
          rows = Math.round @icons.length/columns
        if @options.rows?
          rows = @options.rows
          columns = Math.round @icons.length/rows
        console.log rows, columns
        icpos = @icons.map ((item,i) ->
          if i % columns == 0
            x = 0
            y = if i==0 then y else y+item.base.getSize().y+spacing.y
          else
            x = if i==0 then x else x+item.base.getSize().x+spacing.x
          @size.x = x+item.base.getSize().x
          @size.y = y+item.base.getSize().y
          {x:x, y:y}
          ).bind @
      when 'linear'
        icpos = @icons.map ((item,i) ->
          x = if i==0 then x+x else x+spacing.x+item.base.getSize().x
          y = if i==0 then y+y else y+spacing.y+item.base.getSize().y
          @size.x = x+item.base.getSize().x
          @size.y = y+item.base.getSize().y
          {x:x, y:y}
          ).bind @
      when 'horizontal'
        icpos = @icons.map ((item,i) ->
          x = if i==0 then x+x else x+item.base.getSize().x+spacing.x
          y = if i==0 then y else y
          @size.x = x+item.base.getSize().x
          @size.y = item.base.getSize().y
          {x:x, y:y}
          ).bind @
      when 'vertical'
        icpos = @icons.map ((item,i) ->
          x = if i==0 then x else x
          y = if i==0 then y+y else y+item.base.getSize().y+spacing.y
          @size.x = item.base.getSize().x
          @size.y = y+item.base.getSize().y
          {x:x,y:y}
          ).bind @
      when 'circular'
        n = @icons.length
        radius = @options.radius
        startAngle = @options.startAngle
        ker = 2*@radius*Math.PI
        fok = @options.degree/n
        icpos = @icons.map (item,i) ->
          if i==0
            foks = startAngle * (Math.PI/180)
            x = Math.round(radius * Math.sin(foks))+radius/2+item.base.getSize().x
            y = -Math.round(radius * Math.cos(foks))+radius/2+item.base.getSize().y
          else
            x = Math.round(radius * Math.sin(((fok * i) + startAngle) * (Math.PI/180)))+radius/2+item.base.getSize().x
            y = -Math.round(radius * Math.cos(((fok * i) + startAngle) * (Math.PI/180)))+radius/2+item.base.getSize().y
          {x:x, y:y}
    @base.setStyles {
      width: @size.x
      height: @size.y
    }
    @icons.each (item,i) ->
      item.base.setStyle 'top', icpos[i].y
      item.base.setStyle 'left', icpos[i].x
      item.base.setStyle 'position', 'absolute'
}
