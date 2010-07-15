###
---

name: Core.IconGroup

description: Icon group with 4 types of layout.

license: MIT-style license.

requires: [Core.Abstract]

provides: Core.IconGroup

...
###
Core.Icon: new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Controls
  options:{
    mode:"horizontal" #horizontal / vertical / circular / grid
    spacing: {x:20
              y:20
            }
    startAngle:0 #degree
    radius:0 #degree
    degree:360 #degree
  }
  initialize: (options) ->
    @parent(options)
    @icons: []
    this
  create: ->
    @base.setStyle 'position', 'relative'
  addIcon: (icon) ->
    if @icons.indexOf icon == -1
      @base.grab icon
      @icons.push icon
      yes
    else no
  removeIcon: (icon) ->
    if @icons.indexOf icon != -1
      icon.base.dispose()
      @icons.push icon
      yes
    else no
  ready: ->
    x: 0
    y: 0
    size: {x:0, y:0}
    spacing: @options.spacing
    switch @options.mode
      when 'grid'
        if @options.columns?
          columns=@options.columns;
          rows: @icons.length/columns;
        if @options.rows?
          rows=@options.rows;
          columns=Math.round @icons.length/rows
        icpos: @icons.map (item,i) ->
          if i%columns == 0
            x: 0
            y: if i==0 then y else y+item.base.getSize().y+spacing.y
          else
            x: if i==0 then x else x+item.base.getSize().x+spacing.x
          {x:x,y:y}
      when 'horizontal'
        icpos: @icons.map (item,i) ->
          x: if i==0 then x+x else x+item.base.getSize().x+spacing.x
          y: if i==0 then y else y+spacing.y
          {x:x,y:y}
      when 'vertical'
        icpos: @icons.map (item,i) ->
          x: if i==0 then x else x+spacing.x
          y: if i==0 then y+y else y+item.base.getSize().y+spacing.y
          {x:x,y:y}
      when 'circular'
        n: @icons.length
        radius: @options.radius
        startAngle: @options.startAngle
        ker: 2*@radius*Math.PI
        fok: @options.degree/n
        icpos: @icons.map (item,i) ->
          if i==0
            foks: startAngle*(Math.PI/180)
            x: -Math.round radius*Math.cos(foks)
            y: Math.round radius*Math.sin(foks)
          else
            x: -Math.round radius*Math.cos(((fok*i)+startAngle)*(Math.PI/180))
            y: Math.round radius*Math.sin(((fok*i)+startAngle)*(Math.PI/180))
          {x:x,y:y}
    @icons.each (item,i) ->
      item.base.setStyle 'top', icpos[i].y
      item.base.setStyle 'left', icpos[i].x
      item.base.setStyle 'position', 'absolute'
}