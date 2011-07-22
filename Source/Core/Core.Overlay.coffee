define ["Core.Abstract","Interfaces.Enabled","Interfaces.Controls"], "Core.Overlay", ->
  new Class 
    Extends: Core.Abstract
    Implements: [
      Interfaces.Controls
      Interfaces.Enabled
    ]
    Attributes:
      class:
        value: Lattice.buildClass 'overlay'
      zindex: 
        value: 0
        setter: (value) ->
          @base.setStyle 'z-index', value
          value
        validator: (value) ->
          Number.from(value) isnt null
    create: ->
      @base.setStyles 
        position:"fixed"
        top:0
        left:0
        right:0
        bottom:0
      @hide()
