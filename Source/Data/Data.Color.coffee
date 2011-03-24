###
---

name: Data.Color

description: Color data element. ( color picker )

license: MIT-style license.

requires: 
  - GDotUI
  - Data.Abstract
  - Data.Number
  - Interfaces.Enabled
  - Interfaces.Children
  - Interfaces.Size

provides: Data.Color

...
###
Data.Color = new Class {
  Extends:Data.Abstract
  Binds: ['update']
  Implements: [
    Interfaces.Enabled
    Interfaces.Children
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: GDotUI.Theme.Color.controls.class
    }
    hue: {
      value: 0
      setter: (value) ->
        @hueData.set 'value', value
        value
      getter: ->
        @hueData.value
    }
    saturation: {
      value: 0
      setter: (value) ->
        @saturationData.set 'value', value
        value
      getter: ->
        @saturationData.value
    }
    lightness: {
      value: 100
      setter: (value) ->
        @lightnessData.set 'value', value
        value
      getter: ->
        @lightnessData.value
    }
    alpha: {
      value: 100
      setter: (value) ->
        @alphaData.set 'value', value
        value
      getter: ->
        @alphaData.value
    }
    type: {
      value: 'hex'
      setter: (value) ->
        @col.children.each (item) ->
          if item.label == value
            @col.set 'active', item
        , @
        value
      getter: ->
        if @col.active?
          @col.active.label
    }
    value: {
      setter: (value) ->
        @set 'hue', value.color.hsb[0]
        @set 'saturation', value.color.hsb[1]
        @set 'lightness', value.color.hsb[2]
        @set 'type', value.type
        @set 'alpha', value.alpha
    }
  }
  update: ->
    hue = @get 'hue'
    saturation = @get 'saturation'
    lightness = @get 'lightness'
    type = @get 'type'
    alpha = @get 'alpha'
    if hue? and saturation? and lightness? and type? and alpha?
      ret = $HSB(hue,saturation,lightness)
      ret.setAlpha alpha
      ret.setType type
      @fireEvent 'change', new Hash(ret)
  create: ->
    @addEvent 'sizeChange',( ->
      @col.set 'size', @size
      @hueData.set 'size', @size
      @saturationData.set 'size', @size
      @lightnessData.set 'size', @size
      @alphaData.set 'size', @size
    ).bind @
    
    @hueData = new Data.Number {range:[0,360],reset: off, steps: 360, label:'Hue'}
    @saturationData = new Data.Number {range:[0,100],reset: off, steps: 100 , label:'Saturation'}
    @lightnessData = new Data.Number {range:[0,100],reset: off, steps: 100, label:'Value'}
    @alphaData = new Data.Number {range:[0,100],reset: off, steps: 100, label:'Alpha'}
    
    @col = new Core.PushGroup()
    ['rgb','rgba','hsl','hsla','hex'].each ((item) ->
      @col.addItem new Core.Push({label:item})
    ).bind @
    
    @hueData.addEvent 'change',  @update
    @saturationData.addEvent 'change',  @update
    @lightnessData.addEvent 'change', @update
    @alphaData.addEvent 'change',  @update
    @col.addEvent 'change',  @update
    
    @adoptChildren @hueData, @saturationData, @lightnessData, @alphaData, @col
}
