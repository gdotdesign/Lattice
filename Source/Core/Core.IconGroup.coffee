###
---

name: Core.IconGroup

description: Icon group with 4 types of layout.

license: MIT-style license.

requires: [Core.Abstract, GDotUI]

provides: Core.IconGroup

...
###
Core.IconGroup = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Controls
  Binds: ['delegate']
  options: {
    mode: "horizontal" #horizontal / vertical / circular / grid
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
      @base.grab icon
      @icons.push icon
      yes
    else no
  #show: ->
  #  @base.setStyle 'display', 'block'
  #hide: ->
  #  @base.setStyle 'display', 'none'
  #toggle: ->
  #  if @base.getStyle('display') is 'none'
  #    @show()
  #  else
  #    @hide()
  removeIcon: (icon) ->
    index = @icons.indexOf icon
    if index isnt -1
      icon.removeEvent 'invoked', @delegate
      icon.base.dispose()
      @icons.splice index, 1
      yes
    else no
  ready: ->
    @positionIcons()
  positionIcons: ->
    x = 0
    y = 0
    @size = {x:0, y:0}
    spacing = @options.spacing
    switch @options.mode
      when 'grid'
        if @options.columns?
          columns = @options.columns
          rows = @icons.length / columns
        if @options.rows?
          rows = @options.rows
          columns = Math.round @icons.length/rows
        icpos = @icons.map (item,i) ->
          if i % columns == 0
            x = 0
            y = if i==0 then y else y+item.base.getSize().y+spacing.y
          else
            x = if i==0 then x else x+item.base.getSize().x+spacing.x
          @size.x = x+item.base.getSize().x
          @size.y = y+item.base.getSize().y
          {x:x, y:y}
      when 'linear'
        icpos = @icons.map ((item,i) ->
          x = if i==0 then x+x else x+spacing.x
          y = if i==0 then y+y else y+spacing.y
          @size.x = x+item.base.getSize().x
          @size.y = y+item.base.getSize().y
          {x:x, y:y}
          ).bind @
      when 'horizontal'
        icpos = @icons.map ((item,i) ->
          x = if i==0 then x+x else x+item.base.getSize().x+spacing.x
          y = if i==0 then y else y+spacing.y
          @size.x = x+item.base.getSize().x
          @size.y = item.base.getSize().y
          {x:x, y:y}
          ).bind @
      when 'vertical'
        icpos = @icons.map ((item,i) ->
          x = if i==0 then x else x+spacing.x
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
            x = Math.round radius * Math.sin(foks)
            y = -Math.round radius * Math.cos(foks)
          else
            x = Math.round radius * Math.sin(((fok * i) + startAngle) * (Math.PI/180))
            y = -Math.round radius * Math.cos(((fok * i) + startAngle) * (Math.PI/180))
          {x:x, y:y}
    @icons.each (item,i) ->
      item.base.setStyle 'top', icpos[i].y
      item.base.setStyle 'left', icpos[i].x
      item.base.setStyle 'position', 'absolute'
}
