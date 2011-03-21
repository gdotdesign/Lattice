Layout.Table = new Class {
  Extends: Core.Abstract
  Implements: [Interfaces.Children, Interfaces.Size]
  Attributes: {
    class: {
      value: "layout-table"
    }
  }
  initialize: ->
    @parent arguments
  update: ->
    @children.each (child) ->
      child.set 'size', @size
    , @
  addRow: ->
    @addChild new Layout.Table.Row(arguments)
    
}
Layout.Table.Row = new Class {
  Extends: Core.Abstract
  Implements: [Interfaces.Children, Interfaces.Size]
  Attributes: {
    class: {
      value: "layout-table-row"
    }
  }
  initialie: ->
    @parent arguments
  update: ->
    @children.each (child,i) ->
      child.set 'size', @percentages[i]/100*@size
    , @
  getCell: (n) ->
    @children[n]
  create: ->
    @percentages = []
    arguments.each (item) ->
      @percentages.push Number.from(item)
    if @percentages.sum() isnt 100
      console.log 'Warning: Cells don\'t sum up!'
    @percentages.each (per) ->
      @addChild new Layout.Table.Cell()
    , @
    @addChild new Element('div',{style:{float:'left'}})
    @update()
    
}
Layout.Table.Cell = new Class {
  Extends: Core.Abstract
  Implements: [Interfaces.Children, Interfaces.Size]
  Attributes: {
    class: {
      value: "layout-table-cell"
    }
  }
  initialie: ->
    @parent arguments
  update: ->
    @children.each (child) ->
      child.set 'size', @size
    , @
}
