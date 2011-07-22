define ["Core.Abstract","Interfaces.Enabled","Interfaces.Controls","Interfaces.Size"], "Buttons.Abstract", ->
  new Class
    Extends: Core.Abstract
    Implements:[
      Interfaces.Controls
      Interfaces.Enabled
      Interfaces.Size
    ]
    Attributes:
      label:
        value: ''
        setter: (value) ->
          @base.set 'text', value
          value
      class:
        value: Lattice.buildClass 'button'
    create: ->
      @base.addEvent 'click', (e) =>
        if @enabled
          @fireEvent 'invoked', [@, e]
