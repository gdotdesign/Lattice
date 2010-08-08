###
---

name: Data.Color

description: Color data element. ( color picker )

license: MIT-style license.

requires: Data.Abstract

provides: Data.Color

...
###
Data.Color: new Class {
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
    
    @wrapper: new Element('div').addClass @options.wrapper
    @white: new Element('div').addClass @options.white
    @black: new Element('div').addClass @options.black
    @color: new Element('div').addClass @options.sb
   
    @xyKnob=new Element('div').set 'id', 'xyknob'
    @xyKnob.setStyles {
      'position':'absolute'
      'top':0
      'left':0
      }
    
    @wrapper.adopt @color, @white, @black, @xyKnob
   
    @colorData: new Data.Color.SlotControls()
    @base.adopt @wrapper, @colorData
  ready: ->
    sbSize: @color.getSize()
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
    @xy: new Field @.black, @.xyKnob, {setOnClick:true, x:[0,1,100],y:[0,1,100]}
    @hue: @colorData.hue
    @saturation: @colorData.saturation
    @lightness: @colorData.lightness
    @hue.addEvent 'change',( (step) ->
      if typeof(step) == "object"
        step: 0
      @bgColor.setHue Number(step)
      colr: new $HSB step, 100, 100  
      @color.setStyle 'background-color', colr
      @setColor()
    ).bindWithEvent this
    @saturation.addEvent 'change',( (step) ->
      @xy.set {x:step
         y:@xy.get().y
         }
    ).bindWithEvent this
    @lightness.addEvent 'change',( (step) ->
      @xy.set {x:@xy.get().x
              y:100-step
              }
    ).bindWithEvent this
    @xy.addEvent 'tick', @change
    @xy.addEvent 'change', @change
    @setValue( if @value? then @value else '#fff' )
  setValue: (hex) ->
    if hex?
      @bgColor: new Color hex
    @hue.setValue @bgColor.hsb[0]
    @saturation.setValue @bgColor.hsb[1]
    @lightness.setValue @bgColor.hsb[2]
    @xy.set {x:@bgColor.hsb[1], y:100-@bgColor.hsb[2]}
    colr: new $HSB @bgColor.hsb[0], 100, 100
    @color.setStyle 'background-color', colr
    @setColor()
  setColor: ->
    @finalColor: @bgColor.setSaturation(@saturation.getValue()).setBrightness(@lightness.getValue()).setHue(@hue.getValue())
    
    ret: ''
    switch @options.format
      when "hsl"
        ret: "hsl("+(@finalColor.hsb[0])+", "+(@finalColor.hsb[1])+"%, "+(@finalColor.hsb[2])+"%)"
      when "rgb"
        ret: "rgb("+(@finalColor.rgb[0])+", "+(@finalColor.rgb[1])+", "+(@finalColor.rgb[2])+")"
      else
        ret: "#"+@finalColor.hex.slice(1,7)
    @fireEvent 'change', {color:@finalColor}
    @value: @finalColor
  getValue: ->
    ret: ''
    switch @options.format
      when "hsl"
        ret: "hsl("+(@finalColor.hsb[0])+", "+(@finalColor.hsb[1])+"%, "+(@finalColor.hsb[2])+"%)"
      when "rgb"
        ret: "rgb("+(@finalColor.rgb[0])+", "+(@finalColor.rgb[1])+", "+(@finalColor.rgb[2])+")"
      else
        ret: "#"+@finalColor.hex.slice(1,7)
    ret
  change: (pos) ->
    @saturation.setValue pos.x
    @lightness.setValue 100-pos.y
    @setColor()
}
Data.Color.SlotControls: new Class {
  Extends:Data.Abstract
  options:{
    class:GDotUI.Theme.Color.controls.class
  }
  initialize: (options) ->
    @parent(options)
  create: ->
    @base.addClass @options.class  
    @hue: new Data.Number {range:[0,360],reset: off, steps: [360]}
    @hue.addEvent 'change', ((value) ->
        @saturation.slider.base.setStyle 'background-color', new $HSB(value,100,100)
      ).bindWithEvent this
    @saturation: new Data.Number {range:[0,100],reset: off, steps: [100]}
    @lightness: new Data.Number {range:[0,100],reset: off, steps: [100]}
  ready: ->
    @base.adopt @hue, @saturation, @lightness
}
