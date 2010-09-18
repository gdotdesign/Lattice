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
    
    @wrapper = new Element('div').addClass @options.wrapper
    @white = new Element('div').addClass @options.white
    @black = new Element('div').addClass @options.black
    @color = new Element('div').addClass @options.sb
   
    @xyKnob=new Element('div').set 'id', 'xyknob'
    @xyKnob.setStyles {
      'position':'absolute'
      'top':0
      'left':0
      }
    
    @wrapper.adopt @color, @white, @black, @xyKnob
   
    @colorData = new Data.Color.SlotControls()
  ready: ->
    @base.adopt @wrapper
    sbSize = @color.getSize()
    @wrapper.setStyles {
      width: sbSize.x
      height: sbSize.y
      'position': 'relative'
      'float': 'left'
      }
    $$(@white,@black,@color).setStyles {
      'position': 'absolute'
      'top': 0
      'left': 0
      'width': 'inherit'
      'height': 'inherit'
      }
    @xy = new Field @.black, @.xyKnob, {setOnClick:true, x:[0,1,100],y:[0,1,100]}
    @hue = @colorData.hue
    @saturation = @colorData.saturation
    @lightness = @colorData.lightness
    @alpha = @colorData.alpha
    @colorData.readyCallback = @readyCallback
    @base.adopt @colorData
    @colorData.base.getElements( 'input[type=radio]').each ((item) ->
      item.addEvent 'click',( ->
        @setColor()
      ).bindWithEvent @
    ).bind @
    @alpha.addEvent 'change',( (step) ->
      @setColor()
    ).bindWithEvent this
    @hue.addEvent 'change',( (step) ->
      if typeof(step) == "object"
        step = 0
      @bgColor.setHue Number(step)
      colr = new $HSB step, 100, 100  
      @color.setStyle 'background-color', colr
      @setColor()
    ).bindWithEvent this
    @saturation.addEvent 'change',( (step) ->
      @xy.detach()
      @xy.set {x:step
         y:@xy.get().y
         }
      @xy.attach()
    ).bindWithEvent this
    @lightness.addEvent 'change',( (step) ->
      @xy.detach()
      @xy.set {x:@xy.get().x
              y:100-step
              }
      @xy.attach()
    ).bindWithEvent this
    @xy.addEvent 'tick', @change
    @xy.addEvent 'change', @change
    #@setValue( '#fff', 100, 'hex')
  setValue: (color, alpha, type) ->
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
    console.log @
    @color.setStyle 'background-color', colr
    @setColor()
  setColor: ->
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
      ).bindWithEvent this
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
