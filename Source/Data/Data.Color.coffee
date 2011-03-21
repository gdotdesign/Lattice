###
---

name: Data.Color

description: Color data element. ( color picker )

license: MIT-style license.

requires: [Data.Abstract, GDotUI, Interfaces.Enabled, Interfaces.Children, Data.Number]

provides: Data.Color

...
###
Data.Color = new Class {
  Extends:Data.Abstract
  Implements: [Interfaces.Enabled,Interfaces.Children, Interfaces.Size]
  Binds: ['change']
  Attributes: {
    class: {
      value: GDotUI.Theme.Color.class
    }
  }
  options:{
    wrapper: GDotUI.Theme.Color.wrapper
  }
  initialize: (options) ->
    @parent options

    @angle = 0
    @radius = 0    
    
    #color
    @hue = 0
    @saturation = 0
    @brightness = 100
    
    @center = {}
    #@size = {}
    
    @
  create: ->
    
    @hslacone = $(document.createElement('canvas'))
    @background = $(document.createElement('canvas'))
    @wrapper = new Element('div').addClass @options.wrapper
   
    @knob=new Element('div').set 'id', 'xyknob'
    @knob.setStyles {
      'position':'absolute'
      'z-index': 1
      }
      
    @colorData = new Data.Color.SlotControls()
    @colorData.addEvent 'change', ( ->
      @fireEvent 'change', arguments
    ).bind @
    @base.adopt @wrapper

    @colorData.lightnessData.addEvent 'change',( (step) ->
      @hslacone.setStyle 'opacity',step/100
    ).bind @

    @colorData.hueData.addEvent 'change', ((value) ->
      @positionKnob value, @colorData.get('saturation')
    ).bind @
    
    @colorData.saturationData.addEvent 'change', ((value) ->
      @positionKnob @colorData.get('hue'), value
    ).bind @
    
    @background.setStyles {
      'position': 'absolute'
      'z-index': 0
    }
    
    @hslacone.setStyles {
      'position': 'absolute'
      'z-index': 1
    }
    
    @xy = new Drag.Move @knob
    
    @wrapper.adopt @background, @hslacone, @knob
    @base.grab @colorData
  drawHSLACone: (width,brightness) ->
    ctx = @background.getContext '2d'
    ctx.fillStyle = "#000";
    ctx.beginPath();
    ctx.arc(width/2, width/2, width/2, 0, Math.PI*2, true); 
    ctx.closePath();
    ctx.fill();
    ctx = @hslacone.getContext '2d'
    ctx.translate width/2, width/2
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
  
  update: ->  
    @hslacone.set 'width', @size
    @hslacone.set 'height', @size
    @background.set 'width', @size
    @background.set 'height', @size
    @wrapper.setStyle 'height', @size
    @drawHSLACone @size, 100
    @colorData.set 'size', @size
    
    @knobSize = @knob.getSize()
    @halfWidth = @size/2
    @center = {x: @halfWidth, y:@halfWidth}
    @positionKnob @colorData.get('hue'), @colorData.get('saturation')
  positionKnob: (hue,saturation) ->
    @radius = saturation/100*@halfWidth
    @angle = -((180-hue)*(Math.PI/180))
    @knob.setStyle 'top', -Math.sin(@angle)*@radius-@knobSize.y/2+@center.y
    @knob.setStyle 'left', -Math.cos(@angle)*@radius-@knobSize.x/2+@center.x
  ready: ->
    @update()
    @xy.addEvent 'beforeStart',((el,e) ->
        @lastPosition = el.getPosition(@wrapper)
      ).bind @
    @xy.addEvent 'drag', ((el,e) ->
      if @enabled
        position = el.getPosition(@wrapper)
        
        x = @center.x-position.x-@knobSize.x/2
        y = @center.y-position.y-@knobSize.y/2
        
        @radius = Math.sqrt(Math.pow(x,2)+Math.pow(y,2))
        @angle = Math.atan2(y,x)
        
        if @radius > @halfWidth
          el.setStyle 'top', -Math.sin(@angle)*@halfWidth-@knobSize.y/2+@center.y
          el.setStyle 'left', -Math.cos(@angle)*@halfWidth-@knobSize.x/2+@center.x
          @saturation = 100
        else
          sat =  Math.round @radius 
          @saturation = Math.round((sat/@halfWidth)*100)
        
        an = Math.round(@angle*(180/Math.PI))
        @hue = if an < 0 then 180-Math.abs(an) else 180+an
        @colorData.set 'hue', @hue
        @colorData.set 'saturation', @saturation
      else
        el.setPosition @lastPosition
    ).bind @
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
  Implements: [Interfaces.Enabled,Interfaces.Children,Interfaces.Size]
  Attributes: {
    class: {
      value: GDotUI.Theme.Color.controls.class
    }
    hue: {
      value: 0
      setter: (value) ->
        @hueData.setValue value
        value
      getter: ->
        @hueData.getValue 'value'
    }
    saturation: {
      value: 0
      setter: (value) ->
        @saturationData.setValue value
        value
      getter: ->
        @saturationData.getValue 'value'
    }
    lightness: {
      value: 100
      setter: (value) ->
        @lightnessData.setValue value
        value
    }
    alpha: {
      value: 100
      setter: (value) ->
        @alphaData.setValue value
        value
    }
    type: {
      value: 'hex'
      setter: (value) ->
        @col.children.each (item) ->
          if item.label == value
            @col.setActive item
        , @
        value
    }
  }
  update: ->
    @col.set 'size', @size
    @hueData.set 'size', @size
    @saturationData.set 'size', @size
    @lightnessData.set 'size', @size
    @alphaData.set 'size', @size
    if @hue? and @saturation? and @lightness? and @type? and @alpha?
      @fireEvent 'change', {color:$HSB(@hue,@saturation,@lightness), type:@type, alpha:@alpha} 
  create: ->
    @hueData = new Data.Number {range:[0,360],reset: off, steps: [360], label:'Hue'}
    @hueData.addEvent 'change', ((value) ->
      @set 'hue', value
    ).bind @
    @saturationData = new Data.Number {range:[0,100],reset: off, steps: [100] , label:'Saturation'}
    @saturationData.addEvent 'change', ((value) ->
      @set 'saturation', value
    ).bind @
    @lightnessData = new Data.Number {range:[0,100],reset: off, steps: [100], label:'Lightness'}
    @lightnessData.addEvent 'change', ((value) ->
      @set 'lightness', value
    ).bind @
    @alphaData = new Data.Number {range:[0,100],reset: off, steps: [100], label:'Alpha'}
    @alphaData.addEvent 'change', ((value) ->
      @set 'alpha', value
    ).bind @
    @col = new Core.PushGroup()
    Data.Color.ReturnValues.options.each ((item) ->
      @col.addItem new Core.Push({label:item.label})
    ).bind @
    @col.addEvent 'change', ((value) ->
      @set 'type', value.label
    ).bind @
    @adoptChildren @hueData, @saturationData, @lightnessData, @alphaData, @col
}
