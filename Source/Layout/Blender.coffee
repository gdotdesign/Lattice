Layout.Blender = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Children
  Attributes: {
    class: {
      value: 'blender-layout'
    }
  }
  splitView: (view,mode)->
    @emptyNeigbours()
    view2 = new Layout.Blender.View()
    if mode is 'vertical'
      if view.restrains.bottom
        view.restrains.bottom = no
        view2.restrains.bottom = yes
      top = view.get('top')
      bottom = view.get('bottom')
      view2.set 'top', Math.floor(top+((bottom-top)/2))
      view2.set 'bottom', bottom
      view2.set 'left', view.get('left')
      view2.set 'right', view.get('right')
      view.set 'bottom', Math.floor(top+((bottom-top)/2))
      
    if mode is 'horizontal'
      if view.restrains.right
        view.restrains.right = no
        view2.restrains.right = yes
      left =  view.get('left')
      right = view.get('right')
      view2.set 'top', view.get('top')
      view2.set 'bottom', view.get('bottom')
      view2.set 'left', Math.floor(left+((right-left)/2))
      view2.set 'right', right
      view.set 'right', Math.floor(left+((right-left)/2))
    @addView view2
    @calculateNeigbours()
    @updateToolBars()
  getSimilar: (item,prop)->  
    mod = prop
    switch mod
      when 'right'
        opp = 'left'
      when 'left'
        opp = 'right'
      when 'top'
        opp = 'bottom'
      when 'bottom'
        opp = 'top'
    ret = {
      mod: []
      opp: []
    }
    val = item.get mod
    @children.each (it) ->
      if it isnt item
        v = it.get opp
        if val-5 < v and v < val+5
          ret.opp.push it
        v = it.get mod
        if val-5 < v and v < val+5
          ret.mod.push it
    ret 
  create: ->
    @i = 0
    @stack = {}
    @hooks = []
    @views = []
    @addView new Layout.Blender.View({top:0,left:0,right:"100%",bottom:"100%"
      ,restrains: {top:yes,left:yes,right:yes,bottom:yes}
    })
    console.log 'Blender Layout engine!'
  emptyNeigbours: ->
    @children.each ((child)->
      child.hooks.right = {}
      child.hooks.top = {}
      child.hooks.bottom = {}
      child.hooks.left = {}
    ).bind @
  calculateNeigbours: ->
    @children.each ((child)->
      child.hooks.right = @getSimilar(child,'right')
      child.hooks.top = @getSimilar(child,'top')
      child.hooks.bottom = @getSimilar(child,'bottom')
      child.hooks.left = @getSimilar(child,'left')
    ).bind @
  removeView: (view) ->
    view.removeEvents 'split'
    @removeChild view
  addView: (view) ->
    @addChild view
    view.addEvent 'split', @splitView.bind @
    view.addEvent 'contentChange', ((e)->
      content = new @stack[e]()
      view.content.empty()
      view.content.grab content
    ).bind @
  addToStack: (name,cls) ->
    @stack[name] = cls
    @updateToolBars()
  updateToolBars: ->
    @children.each (child)->
      child.toolbar.select.list.removeAll()
      Object.each @stack, (value,key)->
         @addItem new Iterable.ListItem({label:key,removeable:false,draggable:false})
      , child.toolbar.select
    , @
}
Layout.Blender.View = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Children
  Attributes: {
    class: {
      value: 'blender-view'
    }
    top: {
      setter: (value) ->
        @base.setStyle 'top', value+1
        value
    }
    left: {
      setter: (value) ->
        if String.from(value).test(/%$/)
          value = window.getSize().x*Number.from(value)/100
        @base.setStyle 'left', value
        value
    }
    right: {
      setter: (value) ->
        if String.from(value).test(/%$/)
          value = window.getSize().x*Number.from(value)/100
        @base.setStyle 'right',  window.getSize().x-value+1
        value
    }
    restrains: {
      value: {top: no, left: no, right: no, bottom: no}
    }
    bottom: {
      setter: (value) ->
        if String.from(value).test(/%$/)
          value = window.getSize().y*Number.from(value)/100
        @base.setStyle 'bottom', window.getSize().y-value
        value
    }
  }
  update: ->
    @children.each ((child) ->
      child.set 'size', @base.getSize().x-30
    ).bind @
    @slider.set 'size', @base.getSize().y-60
    if @base.getSize().y < @base.getScrollSize().y
      @slider.show()
    else
      @slider.hide()
  create: ->
    @addEvent 'rightChange', (o)->
      a = @hooks.right
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'right', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'left', o.newVal
    @addEvent 'topChange', (o)->
      a = @hooks.top
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'top', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'bottom', o.newVal
    @addEvent 'bottomChange', (o)->
      a = @hooks.bottom
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'bottom', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'top', o.newVal
    @addEvent 'leftChange', (o)->
      a = @hooks.left
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'left', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'right', o.newVal
    @hooks = {}
    @content = new Element('div.content').inject @base
    @slider = new Core.Slider({steps:100,mode:'vertical'})
    @toolbar = new Layout.Blender.ViewToolbar()
    @toolbar.select.addEvent 'change', ((e)->
      @fireEvent 'contentChange', e
    ).bind @
    @base.adopt @slider, @toolbar

    @position = {x:0,y:0}
    @size = {w:0,h:0}
    @topLeftCorner = new Layout.Blender.Corner({class:'topleft'})
    @topLeftCorner.addEvent 'directionChange',((dir,e) ->
      @fireEvent 'right'
      if (dir is 'bottom' or dir is 'top') and !@restrains.top
        @drag.startpos = {y:Number.from(@base.getStyle('top'))}
        @drag.options.modifiers = {x:null,y:'top'}
        @drag.options.invert = true
        @drag.start(e)
      if (dir is 'bottom' or dir is 'top') and e.control
        @fireEvent 'split',[@,'vertical']
      if (dir is 'left' or dir is 'right') and !@restrains.right
        @drag.startpos = {x:Number.from(@get('right'))}
        @drag.options.modifiers = {x:'right',y:null}
        @drag.options.invert = true
        @drag.start(e)
      if (dir is 'left' or dir is 'right') and e.control
        @fireEvent 'split',[@,'horizontal']
    ).bind @
    @bottomRightCorner = new Layout.Blender.Corner({class:'bottomleft'})
    @bottomRightCorner.addEvent 'directionChange',((dir,e) ->
      if (dir is 'bottom' or dir is 'top') and !@restrains.bottom
        @drag.startpos = {y:Number.from(@get('bottom'))}
        @drag.options.modifiers = {x:null,y:'bottom'}
        @drag.options.invert = true
        @drag.start(e)
      if (dir is 'left' or dir is 'right') and !@restrains.left
        @drag.startpos = {x:Number.from(@base.getStyle('left'))}
        @drag.options.modifiers = {x:'left',y:null}
        @drag.options.invert = true
        @drag.start(e)
    ).bind @
    @adoptChildren @topLeftCorner, @bottomRightCorner
    @drag = new Drag @base, {modifiers:{x:'',y:''}, style:false}
    @drag.detach()
    @drag.addEvent 'drag', ((el,e) ->
      if @drag.options.modifiers.x?
        offset = @drag.mouse.start.x-@drag.mouse.now.x
        if @drag.options.invert
          offset = -offset
        posx = offset+@drag.startpos.x
        @set @drag.options.modifiers.x, if posx > 0 then posx else 0
      if @drag.options.modifiers.y?
        offset = @drag.mouse.start.y-@drag.mouse.now.y
        if @drag.options.invert
          offset = -offset
        posy = offset+@drag.startpos.y
        @set @drag.options.modifiers.y, if posy > 0 then posy else 0
    ).bind @
  check: ->
}
Layout.Blender.ViewToolbar = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Children
  Attributes: {
    class: {
      value: 'blender-toolbar'
    }
  }
  create: ->
    @select = new Data.Select({editable:false,size:80});
    @addChild @select
}
Layout.Blender.Corner = new Class {
  Extends: Core.Icon
  Attributes: {
    snapDistance: {
      value: 0
    }
  }
  create: ->
    @drag = new Drag @base, {style:false}
    @drag.addEvent 'start',((el,e) ->
      @startPosition = e.page
      @direction = null
    ).bind @
    @drag.addEvent 'drag', ((el,e) ->
      directions = []
      offsets = []
      if @startPosition.x < e.page.x 
        directions.push 'right'
        offsets.push e.page.x - @startPosition.x
      if @startPosition.x > e.page.x 
        directions.push 'left'
        offsets.push @startPosition.x - e.page.x
      if @startPosition.y < e.page.y
        directions.push 'bottom'
        offsets.push e.page.y - @startPosition.y
      if @startPosition.y > e.page.y 
        directions.push 'top'
        offsets.push @startPosition.y - e.page.y
      maxdir = directions[offsets.indexOf(offsets.max())]
      maxoffset = offsets.max()
      if maxoffset > @snapDistance
        if @direction isnt maxdir
          @direction = maxdir
          @fireEvent 'directionChange', [maxdir, e]
          @drag.stop()
    ).bind @
    @parent()
}
