define ["Data.Abstract","Interfaces.Size","Interfaces.Enabled"],"Data.Text", ->
  new Class
    Extends: Data.Abstract
    Implements: [
      Interfaces.Size
      Interfaces.Enabled
    ]
    Binds: ['update']  
    Attributes:
      class:
        value: Lattice.buildClass 'textarea'
      value:
        setter: (value) ->
          @text.set 'value', value
          value
        getter: ->
          @text.get 'value'
    update: ->
      @text.setStyle 'width', @size-10
    create: ->
      @text = new Element 'textarea'
      @addEvent 'enabledChange', (obj) =>
        console.log obj
        if obj.newVal
          @text.set 'disabled', false      
        else
          @text.set 'disabled', true
      @base.grab @text
      @text.addEvent 'keyup', =>
        @set 'value', @get 'value'
        @fireEvent 'change', @get 'value'
