###
---

name: Data.Color

description: Color data element. ( color picker )

license: MIT-style license.

requires: [Data.Abstract, Forms.Input]

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
  create: ->
    @base.addClass @options.class
    
    @hslacone = $(document.createElement('canvas'))
    @wrapper = new Element('div').addClass @options.wrapper
   
    @xyKnob=new Element('div').set 'id', 'xyknob'
    @xyKnob.setStyles {
      'position':'absolute'
      }
    @colorData = new Data.Color.SlotControls()
    @bgColor = new Color('#fff')
    @base.adopt @wrapper
  drawHSLACone: (width,brightness) ->
    ctx = @hslacone.getContext '2d'
    ang = width / 50
    angle = (1/ang)*Math.PI/180
    ctx.translate width/2, width/2
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
    @hue = 0
    @saturation = 100
    @wrapper.adopt @xyKnob
    sbSize = @wrapper.getSize()
    @hslacone.set 'width', sbSize.x
    @hslacone.set 'height', sbSize.y
    @wrapper.adopt @hslacone
    @drawHSLACone sbSize.x, 100
    @xy = new Drag.Move @xyKnob
    rad = sbSize.x/2
    size = @xyKnob.getSize()
    @xyKnob.setStyles {left:sbSize.x/2-size.x/2, top:sbSize.y/2-size.y/2}
    center = {x: sbSize.x/2, y:sbSize.y/2}
    
    
    @xy.addEvent 'drag', ((el,e) ->
      position = el.getPosition(@wrapper)
      
      x = center.x-position.x-size.x/2
      y = center.y-position.y-size.y/2
      radius = Math.sqrt(Math.pow(x,2)+Math.pow(y,2))
      angle = Math.atan2(y,x)
      if radius > sbSize.x/2
        el.setStyle 'top', -Math.sin(angle)*rad-size.y/2+center.y
        el.setStyle 'left', -Math.cos(angle)*rad-size.x/2+center.x
        @saturation = 100
      else
        sat =  Math.round radius 
        @saturation = Math.round((sat/rad)*100)
      #console.log radius, size, center, position, angle*(180/Math.PI)
      
      an = Math.round(angle*(180/Math.PI))
      @hue = if an < 0 then 180-Math.abs(an) else 180+an
      c = $HSB(@hue,@saturation,100)
      @hueN.setValue @hue
      @saturationN.setValue @saturation
      $(document.body).setStyle 'background-color', c.hex
    ).bind @
    @hueN = @colorData.hue
    @saturationN = @colorData.saturation
    @lightnessN = @colorData.lightness
    @alpha = @colorData.alpha
    
    @colorData.readyCallback = @readyCallback
    @base.adopt @colorData
   
    ###
    @colorData.base.getElements( 'input[type=radio]').each ((item) ->
      item.addEvent 'click',( ->
        @setColor()
      ).bindWithEvent @
    ).bind @
    
    @alpha.addEvent 'change',( (step) ->
      @setColor()
    ).bindWithEvent @
    @hue.addEvent 'change',( (step) ->
      if typeof(step) == "object"
        step = 0
      @bgColor.setHue Number(step)
      colr = new $HSB step, 100, 100  
      @color.setStyle 'background-color', colr
      @setColor()
    ).bindWithEvent @
    @saturation.addEvent 'change',( (step) ->
      @xy.detach()
      @xy.set {
        x:step
        y:@xy.get().y
        }
      @xy.attach()
    ).bindWithEvent @
    @lightness.addEvent 'change',( (step) ->
      @xy.detach()
      @xy.set {
        x:@xy.get().x
        y:100-step
        }
      @xy.attach()
    ).bindWithEvent @
    @xy.addEvent 'tick', @change
    @xy.addEvent 'change', @change
    ###
  setValue: (color, alpha, type) ->
    ###
    color = new Color(color)
    @hue.setValue color.hsb[0]
    @saturation.setValue color.hsb[1]
    @lightness.setValue color.hsb[2]
    @alpha.setValue alpha
    @colorData.base.getElements( 'input[type=radio]').each (item) ->
      if item.get('value') is type
        item.set 'checked', true
    @xy.set {x: color.hsb[1], y:100-color.hsb[2]}
    colr = new $HSB color.hsb[0], 100, 100
    @bgColor = color
    @finalColor = color
    @color.setStyle 'background-color', colr
    @setColor()
    ###
  setColor: ->
    @finalColor = $HSB(@hue,@saturation,100)
    type = @colorData.base.getElements( 'input[type=radio]:checked')[0].get('value')
    @fireEvent 'change', {color:@finalColor, type:type, alpha:@alpha.getValue()}
    ###
    @finalColor = @bgColor.setSaturation(@saturation.getValue()).setBrightness(@lightness.getValue()).setHue(@hue.getValue())
    type = @colorData.base.getElements( 'input[type=radio]:checked')[0].get('value')
    @fireEvent 'change', {color:@finalColor, type:type, alpha:@alpha.getValue()}
    @value = @finalColor
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
    ###
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
}
