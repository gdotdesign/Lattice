define null, "Interfaces.Size", ->
  new Class
    _$Size: ->
      @size = Number.from Lattice.getCSS ".#{@get('class')}", 'width' or 0
      @minSize = Number.from Lattice.getCSS ".#{@get('class')}", 'min-width' or 0
      @addAttribute 'minSize',
        value: null
        setter: (value,old) ->
          @base.setStyle 'min-width', value
          if @size < value
            @set 'size', value
          value      
      @addAttribute 'size',
        value: null
        setter: (value, old) ->
          size = if value < @minSize then @minSize else value
          @base.setStyle 'width', size
          size
