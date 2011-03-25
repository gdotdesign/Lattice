#viewStack
Layout.Blender = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Children
  Attributes: {
    class: {
      value: 'blender-layout'
    }
  }
  splitView: (view,mode)->
    view2 = new Layout.Blender.View()
    @addView view2
    if mode is 'vertical'
      if view.restrains.bottom
        view.restrains.bottom = no
        view2.restrains.bottom = yes
      else
        if view.hooks.bottom?
          view.hooks.bottom.replaceView view, view2
      hook = new Layout.Blender.Hook {ob: view, prop: 'bottom'}, {ob: view2, prop: 'top'}
      view.hooks.bottom = hook
      view2.hooks.top = hook
      top = view.get('top')
      bottom = view.get('bottom')
      view2.set 'top', Math.floor(top+((bottom-top)/2))
      view2.set 'bottom', bottom
      view2.set 'left', view.get('left')
      view2.set 'right', view.get('right')
      
      
      if view.restrains.right
        view2.restrains.right = yes
      else
        new Layout.Blender.Hook {ob: view, prop: 'right'}, {ob: view2, prop: 'right'}
        view.hooks.right = hook
        view2.hooks.right = hook
      if view.restrains.left
        view2.restrains.left = yes
      else
        new Layout.Blender.Hook {ob: view,prop: 'left'}, {ob: view2,prop: 'left'}
        view.hooks.left = hook
        view2.hooks.left = hook
        
    if mode is 'horizontal'
      if view.restrains.right
        view.restrains.right = no
        view2.restrains.right = yes
      if view.hooks.right?
        view.hooks.right.replaceView view, view2
      hook = new Layout.Blender.Hook {ob: view, prop: 'right'}, {ob: view2, prop: 'left'}
      view.hooks.right = hook
      view2.hooks.left = hook
      left =  view.get('left')
      right = view.get('right')
      view2.set 'top', view.get('top')
      view2.set 'bottom', view.get('bottom')
      view2.set 'left', Math.floor(left+((right-left)/2))
      view2.set 'right', right
      if view.restrains.top
        view2.restrains.top = yes
      else
        new Layout.Blender.Hook {ob: view,prop: 'top' }, {ob: view2,prop: 'top'}
        view.hooks.top = hook
        view2.hooks.top = hook
      if view.restrains.bottom
        view2.restrains.bottom = yes
      else
        hook = new Layout.Blender.Hook {ob: view, prop: 'bottom'}, {ob: view2, prop: 'bottom'}
        view.hooks.bottom = hook
        view2.hooks.bottom = hook
  create: ->
    @views = []
    @addView new Layout.Blender.View({top:0,left:0,right:"100%",bottom:"100%"
      ,restrains: {top:yes,left:yes,right:yes,bottom:yes}
    })
    
    #@splitView view,'horizontal'
    #@splitView view,'vertical'
    #@views.push view
    ###
    view = new Layout.Blender.View({top:30,left:0,right:"80%",bottom:300})
    view.base.setStyle 'background-image', 'url(/Themes/Chrome/images/grid5.png)'
    view1 = new Layout.Blender.View({top:300,left:0,right:"100%",bottom:"100%"})
    view2 = new Layout.Blender.View({top:0,left:"80%",right:"100%",bottom:150})
    view3 = new Layout.Blender.View({top:150,left:"80%",right:"100%",bottom:300})
    pg = new Core.PushGroup()
    list = ['html','css','values']
    list.each (item)->
      pg.addItem new Core.Push({label:item,removeable:false,draggable:false})
    view3.addChild pg
    view4 = new Layout.Blender.View({top:0,left:0,right:"80%",bottom:30})
    view2.addChild new Element 'div.dialog-prompt-label', {text:'Value'}
    view2.addChild new Data.Number();
    view2.addChild new Element 'div.dialog-prompt-label', {text:'Value'}
    tip = new Core.Tip({label:'Heey youuu!',zindex:100,location:{x:'auto',y:'auto'},offset:10});
    select = new Data.Select();
    tip.attach select
    view2.addChild select
    list = [' bounding-box','each-box','continuous','border-box','padding-box','content-box','no-clip']
    list.each (item)->
      select.addItem new Iterable.ListItem({label:item,removeable:false,draggable:false})
    
    new Layout.Blender.Hook {
      ob: view4
      prop: 'bottom'
    }, {
      ob: view
      prop: 'top'
    }
    new Layout.Blender.Hook {
      ob: view4
      prop: 'right'
    }, {
      ob: view
      prop: 'right'
    }
    new Layout.Blender.Hook {
      ob: view
      prop: 'bottom'
    }, {
      ob: view1
      prop: 'top'
    }
    new Layout.Blender.Hook {
      ob: view2
      prop: 'left'
    }, {
      ob: view3
      prop: 'left'
    }
    new Layout.Blender.Hook {
      ob: view2
      prop: 'bottom'
    }, {
      ob: view3
      prop: 'top'
    }
    new Layout.Blender.Hook {
      ob: view
      prop: 'bottom'
    }, {
      ob: view3
      prop: 'bottom'
    }
    new Layout.Blender.Hook {
      ob: view
      prop: 'right'
    }, {
      ob: view2
      prop: 'left'
    }
    view.addEvent 'topleft-bottom', ((e) ->
      console.log 'hehe?'
      @addChild new Layout.Blender.View()
    ).bind @
    @adoptChildren view, view1, view2, view3, view4
    ###
    console.log 'Blender Layout engine!'
  getView: (e) ->
  addView: (view) ->
    @views.push
    @addChild view
    view.addEvent 'split', @splitView.bind @
}
Layout.Blender.Hook = new Class {
  initialize: (side1,side2) ->
    @side1 = side1
    @side2 = side2
    @attach()
    @
  getOther: (view)->
    if view is @side1.ob
      @side2.ob
    else
      @side1.ob
  attach: ->
    @side1.ob.addEvent "#{@side1.prop}Change",((obj) ->
      @side2.ob.set @side2.prop, obj.newVal
    ).bind @
    @side2.ob.addEvent "#{@side2.prop}Change",((obj) ->
      @side1.ob.set @side1.prop, obj.newVal
    ).bind @
  detach: ->
    @side1.ob.removeEvents "#{@side1.prop}Change"
    @side2.ob.removeEvents "#{@side2.prop}Change"
  replaceView: (view,replacement)->
    @detach()
    if view is @side1.ob
      @side1.ob = replacement
    if view is @side2.ob
      @side2.ob = replacement  
    @attach()
    
  
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
          value = window.getScrollSize().x*Number.from(value)/100
        @base.setStyle 'left', value
        value
    }
    right: {
      setter: (value) ->
        if String.from(value).test(/%$/)
          value = window.getScrollSize().x*Number.from(value)/100
        @base.setStyle 'right',  window.getScrollSize().x-value+1
        value
    }
    restrains: {
      value: {top: no, left: no, right: no, bottom: no}
    }
    bottom: {
      setter: (value) ->
        if String.from(value).test(/%$/)
          value = window.getScrollSize().y*Number.from(value)/100
        @base.setStyle 'bottom', window.getScrollSize().y-value
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
    @hooks = {top: null, left: null, right: null, bottom: null}
    @slider = new Core.Slider({steps:100,mode:'vertical'})
    @toolbar = new Layout.Blender.ViewToolbar()
    console.log @toolbar
    @base.adopt @slider, @toolbar

    @position = {x:0,y:0}
    @size = {w:0,h:0}
    @topLeftCorner = new Layout.Blender.Corner({class:'topleft'})
    @topLeftCorner.addEvent 'directionChange',((dir,e) ->
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
    ###
    @base.addEvent 'mousemove', ((e) ->
      cd = @base.getCoordinates()    
      topoffset = Math.abs(e.client.y-cd.top)
      bottomoffset = Math.abs(e.client.y-cd.bottom)
      leftoffset = Math.abs(e.client.x-cd.left)
      rightoffset = Math.abs(e.client.x-cd.right)
      if bottomoffset < 6
        @base.setStyle 'cursor', 's-resize'
      else if topoffset < 6
        @base.setStyle 'cursor', 'n-resize'
      else if leftoffset < 6
        @base.setStyle 'cursor', 'w-resize'
      else if rightoffset < 6
        @base.setStyle 'cursor', 'e-resize'
      else
        @base.setStyle 'cursor', 'auto'
    ).bind @
    @base.addEvent 'mousedown', ((e) ->
      cd = @base.getCoordinates()    
      topoffset = Math.abs(e.client.y-cd.top)
      bottomoffset = Math.abs(e.client.y-cd.bottom)
      leftoffset = Math.abs(e.client.x-cd.left)
      rightoffset = Math.abs(e.client.x-cd.right)
      console.log leftoffset, rightoffset
      @drag.options.modifiers = {x:'',y:''}
      if bottomoffset < 6
        @drag.options.modifiers.y = 'bottom'
        @drag.options.invert = true
      if topoffset < 6
        @drag.options.modifiers.y = 'top'
        @drag.options.invert = false
      if leftoffset < 6
        @drag.options.modifiers.x = 'left'
        @drag.options.invert = false
      if rightoffset < 6
        @drag.options.modifiers.x = 'right'
        @drag.options.invert = true
      @drag.start(e)
    
    ).bind @
    ###
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
    select = new Data.Select({editable:false,size:80});
    list = ['node editor','preview','setting','library','help','info']
    list.each (item)->
      select.addItem new Iterable.ListItem({label:item,removeable:false,draggable:false})
    @addChild select
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
    #@drag.addevent 'complete', ->
    #  @fireEvet 'complete'
    @parent()
}
###
Layout.Table = new Class {
  Extends: Core.Abstract
  Implements: [Interfaces.Children, Interfaces.Size]
  Attributes: {
    class: {
      value: "layout-table"
    }
  }
  initialize: ->
    @parent arguments
  update: ->
    @children.each (child) ->
      child.set 'size', @size
    , @
  addRow: ->
    @addChild new Layout.Table.Row(arguments)
    
}
Layout.Table.Row = new Class {
  Extends: Core.Abstract
  Implements: [Interfaces.Children, Interfaces.Size]
  Attributes: {
    class: {
      value: "layout-table-row"
    }
  }
  initialie: ->
    @parent arguments
  update: ->
    @children.each (child,i) ->
      child.set 'size', @percentages[i]/100*@size
    , @
  getCell: (n) ->
    @children[n]
  create: ->
    @percentages = []
    arguments.each (item) ->
      @percentages.push Number.from(item)
    if @percentages.sum() isnt 100
      console.log 'Warning: Cells don\'t sum up!'
    @percentages.each (per) ->
      @addChild new Layout.Table.Cell()
    , @
    @addChild new Element('div',{style:{float:'left'}})
    @update()
    
}
Layout.Table.Cell = new Class {
  Extends: Core.Abstract
  Implements: [Interfaces.Children, Interfaces.Size]
  Attributes: {
    class: {
      value: "layout-table-cell"
    }
  }
  initialie: ->
    @parent arguments
  update: ->
    @children.each (child) ->
      child.set 'size', @size
    , @
}
###
