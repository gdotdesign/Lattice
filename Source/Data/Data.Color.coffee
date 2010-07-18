###
---

name: Data.Color

description: 

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
    this
  create: ->
    @base.addClass @options.class
    # SB Start
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
    # SB END 
    # Hue Start 
    # @color_linear: new Element('div').addClass @options.hue
    # @colorKnob: new Element 'div', {'id':'knob'}
    # @color_linear.grab @colorKnob
    # Hue End 
    
   
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
    @setValue( if @value then @value else '#fff' )
  setValue: (hex) ->
    if hex?
      @bgColor: new Color hex
    @hue.setValue @bgColor.hsb[0]
    @saturation.setValue @bgColor.hsb[1]
    @lightness.setValue @bgColor.hsb[2]
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
    @fireEvent 'change', [ret]
    @value: @finalColor
  change: (pos) ->
    @saturation.setValue pos.x
    @lightness.setValue 100-pos.y
    @setColor()
}
Data.Color.SlotControls: new Class {
  Extends:Data.Abstract
  options:{
    class:GDotUI.Theme.Color.slotControls.class
  }
  initialize: (options) ->
    @parent(options)
    this
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
Data.Color.Controls: new Class {
    Extends:Data.Abstract
    options:{
        class: GDotUI.Theme.Color.controls.class
        format: GDotUI.Theme.Color.controls.format
        colorBox: GDotUI.Theme.Color.controls.colorBox
    }
    initialize: (options) ->
        @parent(options)
        this
    create: ->
        @base.addClass @options.class
        
        @left: new Element('div').setStyles {'float': 'left'}
        @red: new Data.Color.Controls.Field 'R'
        @green: new Data.Color.Controls.Field 'G'
        @blue: new Data.Color.Controls.Field 'B'
        @left.adopt @red, @green, @blue
        
        @right: new Element 'div'
        @right.setStyles {'float':'left'}
        @hue: new Data.Color.Controls.Field 'H'
        @saturation: new Data.Color.Controls.Field 'S'
        @brightness: new Data.Color.Controls.Field 'B'
        @right.adopt @hue, @saturation, @brightness
        
        @color: new Element('div').setStyles({'float':'left'}).addClass @options.colorBox
        
        @format: new Element('div').setStyles({'float':'left'}).addClass @options.format
        @hex: new Data.Color.Controls.Field 'Hex'
        @rgb: new Data.Color.Controls.Field 'RGB'
        @hsb: new Data.Color.Controls.Field 'HSL'
        @format.adopt @hex, @rgb, @hsb
        
        @base.adopt @left, @right, @color, new Element('div').setStyle('clear','both'), @format
    setValue: (color) ->
        @color.setStyle 'background-color', color
        @red.input.set 'value', color.rgb[0]
        @green.input.set 'value', color.rgb[1]
        @blue.input.set 'value', color.rgb[2]
        @rgb.input.set 'value', "rgb("+(color.rgb[0])+", "+(color.rgb[1])+", "+(color.rgb[2])+")"
        @hue.input.set 'value', color.hsb[0]
        @saturation.input.set 'value', color.hsb[1]
        @brightness.input.set 'value', color.hsb[2]
        @hsb.input.set 'value', "hsl("+(color.hsb[0])+", "+(color.hsb[1])+"%, "+(color.hsb[2])+"%)"
        @hex.input.set 'value', "#"+color.hex.slice(1,7)
}
# to be replaced by Form.Field
Data.Color.Controls.Field: new Class {
  initialize: (label) ->
    @base: new Element 'dl'
    @input: new Element 'input', {type:'text'
                                  readonly:true}
    @label: new Element 'label', {text:label+": "}
    @dt: new Element('dt').grab @label
    @dd: new Element('dd').grab @input
    @base.adopt @dt,@dd
    this
  toElement: ->
    @base
}