###
---

name: Core.Float

description: Core.Float is a "floating" panel, with controls. Think of it as a window, just more awesome.

license: MIT-style license.

requires: [Core.Abstract, Interfaces.Draggable, Interfaces.Restoreable, Core.Slider, Core.IconGroup, GDotUI]

provides: Core.Float

...
###
Core.Float = new Class {
  Extends:Core.Abstract
  Implements:[Interfaces.Draggable
              Interfaces.Restoreable]
  Binds:['resize'
         'mouseEnter'
         'mouseLeave'
         'hide'
         ]
  options:{
    classes:{
      class: GDotUI.Theme.Float.class
      controls: GDotUI.Theme.Float.controls
      content: GDotUI.Theme.Float.content
      handle: GDotUI.Theme.Float.topHandle
      bottom: GDotUI.Theme.Float.bottomHandle
      active: GDotUI.Theme.Global.active
      inactive: GDotUI.Theme.Global.inactive
    }
    iconOptions: GDotUI.Theme.Float.iconOptions
    icons:{
      remove: GDotUI.Theme.Icons.remove
      edit: GDotUI.Theme.Icons.edit
    }
    closeable: on
    resizeable: off
    editable: off
    draggable: on
    ghost: off
    overlay: off
  }
  initialize: (options) ->
    @showSilder = off
    @readyr = no
    @parent options
  ready: ->
    @base.adopt @controls
    if @contentElement?
      @content.grab @contentElement
    if @options.restoreable
      @loadPosition()
    else
      @base.position()
    if @scrollBase.getScrollSize().y > @scrollBase.getSize().y
          if not @showSlider
            @showSlider = on
            if @mouseisover
              @slider.show()
    @parent()
    @readyr = yes
  create: ->
    @base.addClass @options.classes.class
    @base.setStyle 'position', 'fixed'
    @base.setPosition {x:0,y:0}
    @base.toggleClass @options.classes.inactive
    
    @controls =  new Element 'div', {class: @options.classes.controls}
    @content = new Element 'div', {'class': @options.classes.content}
    @handle = new Element 'div', {'class': @options.classes.handle}
    @bottom = new Element 'div', {'class': @options.classes.bottom}

    @base.adopt @handle, @content
    
    sliderSize = getCSS("/\\.#{@options.classes.class} .#{GDotUI.Theme.Slider.classes.base}$/",'height') or 100
    console.log sliderSize
    @slider = new Core.Slider {scrollBase:@content, range:[0,100], steps: 100, mode:'vertical', size: sliderSize}
    @slider.addEvent 'complete', ( ->
      console.log 'complete'
      @scrolling = off
    ).bind @
    @slider.addEvent 'step', ((e)->
      @scrollBase.scrollTop = ((@scrollBase.scrollHeight-@scrollBase.getSize().y)/100)*e
      @scrolling = on
    ).bind @
    
    @slider.hide()
    
    @icons = new Core.IconGroup @options.iconOptions
    @controls.adopt @icons, @slider
    
    @close = new Core.Icon {image: @options.icons.remove}
    @close.addEvent 'invoked', ( ->
      @hide()
    ).bindWithEvent @

    @edit = new Core.Icon {image:@options.icons.edit}
    @edit.addEvent 'invoked', ( ->
      if @contentElement?
        if @contentElement.toggleEdit?
          @contentElement.toggleEdit()
        @fireEvent('edit')
    ).bindWithEvent @
    
    if @options.closeable
      @icons.addIcon @close
    if @options.editable
      @icons.addIcon @edit
    
    @icons.hide()
    
    if @options.scrollBase? 
      @scrollBase = @options.scrollBase
    else
      @scrollBase = @content
    
    @scrollBase.setStyle 'overflow', 'hidden'
    
    if @options.resizeable
      @base.grab @bottom
      @sizeDrag = new Drag @scrollBase, {handle:@bottom, modifiers:{x:'',y:'height'}}
      @sizeDrag.addEvent 'drag', ( ->
        if @scrollBase.getScrollSize().y > @scrollBase.getSize().y
          if not @showSlider
            @showSlider = on
            if @mouseisover
              @slider.show()
        else
          if @showSlider
            @showSlider = off
            @slider.hide()
        ).bindWithEvent @
        @scrollBase.addEvent 'mousewheel',( (e) ->
          @scrollBase.scrollTop = @scrollBase.scrollTop+e.wheel*12
          @slider.set @scrollBase.scrollTop/(@scrollBase.scrollHeight-@scrollBase.getSize().y)*100
        ).bindWithEvent @
    @base.addEvent 'mouseenter', ( ->
      @base.toggleClass @options.classes.active
      @base.toggleClass @options.classes.inactive
      $clear @iconsTimout
      $clear @sliderTimout
      if @showSlider
        @slider.show()
      @icons.show()
      @mouseisover = on 
    ).bindWithEvent @
    @base.addEvent 'mouseleave', ( ->
      @base.toggleClass @options.classes.active
      @base.toggleClass @options.classes.inactive
      if not @scrolling
        if @showSlider
          @sliderTimout = @slider.hide.delay 200, @slider
      @iconsTimout = @icons.hide.delay 200, @icons
      @mouseisover = off 
    ).bindWithEvent @
    if @options.overlay
      @overlay = new Core.Overlay()
  show: ->
    if @options.overlay
      document.getElement('body').grab @overlay
      @overlay.show()
    document.getElement('body').grab @base
    @saveState()
  hide: ->
    if @options.overlay
      @overlay.base.dispose()
    @base.dispose()
    @saveState()
  toggle: (el) ->
    if @base.isVisible()
      @hide el
    else
      @show el
  setContent: (element) -> 
    @contentElement = element
    if @readyr
      @content.getChildren().dispose()
      @content.grab @contentElement
      if @scrollBase.getScrollSize().y > @scrollBase.getSize().y
        @showSlider = on
        if @mouseisover
          @slider.show()
      else
        @showSlider = off
        @slider.hide()
  center: ->
    @base.position()
}
