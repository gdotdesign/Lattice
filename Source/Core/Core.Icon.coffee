define ["Core.Abstract","Interfaces.Enabled","Interfaces.Controls"], "Core.Icon", ->
  new Class
    Extends: Core.Abstract
    Implements:[
      Interfaces.Controls
      Interfaces.Enabled
    ]
    Attributes:
      image:
        setter: (value) ->
          @setStyle 'background-image', 'url(' + value + ')'
          value
      class:
        value: Lattice.buildClass 'icon'
    create: ->
      @base.addEvent 'click', (e) =>
        if @enabled
          @fireEvent 'invoked', [@, e]
