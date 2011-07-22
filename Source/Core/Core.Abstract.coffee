define ["Lattice","Class.Mutators.Attributes","Interfaces.Mux"],"Core.Abstract", ->
  new Class 
    Implements:[
      Events
      Interfaces.Mux
    ]
    Delegates: 
      base: ['setStyle','getStyle','setStyles','getStyles','dispose']
    Attributes: 
      class: 
        setter: (value, old) ->
          value = String.from value
          @base.replaceClass value, old
          value
    getSize: ->
      comp = @base.getComputedSize({styles:['padding','border','margin']})
      {x:comp.totalWidth, y:comp.totalHeight}
    initialize: (attributes) ->
      @base = new Element 'div'
      @base.addEvent 'addedToDom', @ready.bind @
      @mux()
      @create()
      @setAttributes attributes
      Lattice.Elements.push @
      @
    create: ->
    update: ->
    ready: ->
      @base.removeEvents 'addedToDom'
    toElement: ->
      @base
