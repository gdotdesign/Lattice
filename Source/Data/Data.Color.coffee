###
---

name: Data.Color

description: Color data element. ( color picker )

license: MIT-style license.

requires: [Data.Abstract, Forms.Input, GDotUI]

provides: Data.Color

...
###
Data.Color = new Class {
  Extends:Data.Abstract
  Binds: ['change']
  options:{
    class: GDotUI.Theme.Color.class
    sb: GDotUI.Theme.Color.sb
    hue: GDotUI.Theme.Color.hue 
    wrapper: GDotUI.Theme.Color.wrapper
    white: GDotUI.Theme.Color.white
    black: GDotUI.Theme.Color.black
    format: GDotUI.Theme.Color.format
  }
  initialize: (options) ->
    @parent(options)

    @angle = 0
    @radius = 0    
    
    #color
    @hue = 0
    @saturation = 0
    @brightness = 100
    
    @center = {}
    @size = {}
    
    @
  create: ->
    @base.addClass @options.class
    
    @hslacone = $(document.createElement('canvas'))
    @background = $(document.createElement('canvas'))
    @wrapper = new Element('div').addClass @options.wrapper
   
    @knob=new Element('div').set 'id', 'xyknob'
    @knob.setStyles {
      'position':'absolute'
      'z-index': 1
      }
      
    @colorData = new Data.Color.SlotControls()
    @bgColor = new Color('#fff')
    @base.adopt @wrapper
    @hueN = @colorData.hue
    @saturationN = @colorData.saturation
    @lightness = @colorData.lightness
    @alpha = @colorData.alpha
    @hueN.addEvent 'change',( (step) ->
      if typeof(step) == "object"
        step = 0
      @setHue(step)
    ).bindWithEvent @
    @saturationN.addEvent 'change',( (step) ->
      @setSaturation step
    ).bindWithEvent @
    @lightness.addEvent 'change',( (step) ->
      @hslacone.setStyle 'opacity',step/100
      @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
    ).bindWithEvent @
    
  drawHSLACone: (width,brightness) ->
    ctx = @hslacone.getContext '2d'
    w2 = -width/2
    ang = width / 50
    angle = (1/ang)*Math.PI/180
    i = 0
    for i in [0..(360)*(ang)-1]
      c = $HSB(360+(i/ang),100,brightness)
      c1 = $HSB(360+(i/ang),0,brightness)
      grad = ctx.createLinearGradient(0,0,width/2,0)
      grad.addColorStop(0, c1.hex)
      grad.addColorStop(1, c.hex)
      ctx.strokeStyle = grad
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.lineTo(width/2,0)
      ctx.stroke()
      ctx.rotate(angle)
      
  ready: ->
    @width = @wrapper.getSize().x
    
    @background.setStyles {
      'background-color': "#000"
      '-webkit-border-radius': @width/2+"px"
      'position': 'absolute'
      'z-index': -3
    }
    
    @hslacone.setStyles {
      'position': 'absolute'
      'z-index': 0
    }
    
    @hslacone.set 'width', @width
    @hslacone.set 'height', @width
    @background.set 'width', @width
    @background.set 'height', @width
    
    @wrapper.adopt @background, @hslacone, @knob
    
    ctx = @hslacone.getContext '2d'
    ctx.translate @width/2, @width/2
    @drawHSLACone @width, 100
    
    @xy = new Drag.Move @knob
    
    @halfWidth = @width/2
    @size = @knob.getSize()
    @knob.setStyles {left:@halfWidth-@size.x/2, top:@halfWidth-@size.y/2}
    
    @center = {x: @halfWidth, y:@halfWidth}
    
    
    @xy.addEvent 'drag', ((el,e) ->
      position = el.getPosition(@wrapper)
      
      x = @center.x-position.x-@size.x/2
      y = @center.y-position.y-@size.y/2
      
      @radius = Math.sqrt(Math.pow(x,2)+Math.pow(y,2))
      @angle = Math.atan2(y,x)
      
      if @radius > @halfWidth
        el.setStyle 'top', -Math.sin(@angle)*@halfWidth-@size.y/2+@center.y
        el.setStyle 'left', -Math.cos(@angle)*@halfWidth-@size.x/2+@center.x
        @saturation = 100
      else
        sat =  Math.round @radius 
        @saturation = Math.round((sat/@halfWidth)*100)
      
      an = Math.round(@angle*(180/Math.PI))
      @hue = if an < 0 then 180-Math.abs(an) else 180+an
      @hueN.setValue @hue
      @saturationN.setValue @saturation
      @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
    ).bind @
   
    
    @colorData.readyCallback = @readyCallback
    @base.adopt @colorData
    
   
    
    @colorData.base.getElements( 'input[type=radio]').each ((item) ->
      item.addEvent 'click',( (e)->
        @type = @colorData.base.getElements( 'input[type=radio]:checked')[0].get('value')
        @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
      ).bindWithEvent @
    ).bind @
    
    @alpha.addEvent 'change',( (step) ->
      @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
    ).bindWithEvent @
    @parent()
  readyCallback: ->  
    @alpha.setValue 100
    @lightness.setValue 100
    @hue.setValue 0
    @saturation.setValue 0
    delete @readyCallback
  setHue: (hue) ->
    @angle = -((180-hue)*(Math.PI/180))
    @hue = hue
    @knob.setStyle 'top', -Math.sin(@angle)*@radius-@size.y/2+@center.y
    @knob.setStyle 'left', -Math.cos(@angle)*@radius-@size.x/2+@center.x
    @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
  setSaturation: (sat) ->
    @radius = sat
    @saturation = sat
    @knob.setStyle 'top', -Math.sin(@angle)*@radius-@size.y/2+@center.y
    @knob.setStyle 'left', -Math.cos(@angle)*@radius-@size.x/2+@center.x
    @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()} 
  setValue: (color, alpha, type) ->
    @hue = color.hsb[0]
    @saturation = color.hsb[1]
    @angle = -((180-color.hsb[0])*(Math.PI/180))
    @radius = color.hsb[1]
    @knob.setStyle 'top', -Math.sin(@angle)*@radius-@size.y/2+@center.y
    @knob.setStyle 'left', -Math.cos(@angle)*@radius-@size.x/2+@center.x
    @hueN.setValue color.hsb[0]
    @saturationN.setValue color.hsb[1]
    @alpha.setValue alpha
    @lightness.setValue color.hsb[2]
    @hslacone.setStyle 'opacity',color.hsb[2]/100
    @colorData.base.getElements( 'input[type=radio]').each ((item) ->
      if item.get('value') == type
        item.set 'checked', true
    ).bind @
    @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness.getValue()), type:@type, alpha:@alpha.getValue()}
  setColor: ->
    @finalColor = $HSB(@hue,@saturation,100)
    type = 
    @fireEvent 'change', {color:@finalColor, type:type, alpha:@alpha.getValue()}
  getValue: ->
    @finalColor
  change: (pos) ->
    @saturation.slider.slider.detach()
    @saturation.setValue pos.x
    @saturation.slider.slider.attach()
    @lightness.slider.slider.detach()
    @lightness.setValue 100-pos.y
    @lightness.slider.slider.attach()
    @setColor()
}
Data.Color.ReturnValues = {
  type: 'radio'
  name: 'col'
  options: [
    {
      label: 'rgb'
      value: 'rgb'
    }
    {
      label: 'rgba'
      value: 'rgba'
    }
    {
      label: 'hsl'
      value: 'hsl'
    }
    {
      label: 'hsla'
      value: 'hsla'
    }
    {
      label: 'hex'
      value: 'hex'
    }
  ]
}
Data.Color.SlotControls = new Class {
  Extends:Data.Abstract
  options:{
    class:GDotUI.Theme.Color.controls.class
  }
  initialize: (options) ->
    @parent(options)
  create: ->
    @base.addClass @options.class  
    @hue = new Data.Number {range:[0,360],reset: off, steps: [360]}
    @hue.addEvent 'change', ((value) ->
        @saturation.slider.base.setStyle 'background-color', new $HSB(value,100,100)
      ).bindWithEvent @
    @saturation = new Data.Number {range:[0,100],reset: off, steps: [100]}
    @lightness = new Data.Number {range:[0,100],reset: off, steps: [100]}
    @alpha = new Data.Number {range:[0,100],reset: off, steps: [100]}
    @col = new Forms.Input Data.Color.ReturnValues
  ready: ->
    @base.adopt @hue, @saturation, @lightness, @alpha, @col
    @base.getElements('input[type=radio]')[0].set('checked',true)
    if @readyCallback?
      @readyCallback()
    @parent()
}
