###
---

name: Data.Table

description: Text data element.

requires: Data.Abstract

provides: Data.Table

...
###
checkForKey: (key,hash,i) ->
  if not i?
    i: 0
  if not hash[key]?
    key
  else
    if not hash[key+i]?
      key+i
    else
      checkForKey key,hash,i+1
Data.Table: new Class {
  Extends: Data.Abstract
  Binds: ['update']
  options: {
    columns: 1
    class: GDotUI.Theme.Table.class
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @table: new Element 'table', {cellspacing:0, cellpadding:0}
    @base.grab @table
    @rows: []
    @columns: @options.columns
    @header: new Data.TableRow {columns:@columns}
    @header.addEvent 'next', ( ->
      @addCloumn()
      @header.cells.getLast().editStart()
    ).bindWithEvent @
    @header.addEvent 'editEnd', ( ->
      if not @header.cells.getLast().editing
        if @header.cells.getLast().getValue() is ''
          @removeLast()
    ).bindWithEvent @
    @table.grab @header
    @addRow(@columns)
    @
  ready: ->
  addCloumn: ->
    @columns++
    @header.add ''
    @rows.each (item) ->
      item.add ''
  removeLast: () ->
    @header.removeLast()
    @columns--
    @rows.each (item) ->
      item.removeLast()
  addRow: (columns) ->
    row: new Data.TableRow({columns:columns})
    row.addEvent 'editEnd', @update
    row.addEvent 'next', ((row) ->
      index: @rows.indexOf row
      if index isnt @rows.length-1
        @rows[index+1].cells[0].editStart()
    ).bindWithEvent @
    @rows.push row
    #sortable here 
    @table.grab row
  removeRow: (row) ->
    row.removeEvents 'editEnd'
    row.removeEvents 'next'
    row.removeAll()
    @rows.erase row
    row.base.destroy()
    delete row
  removeAll: ->
    @header.removeAll()
    (@rows.filter -> true).each ( (row) ->
      @removeRow row
    ).bind @
    @columns: 0
    @addCloumn()
    @addRow @columns
  update: ->
    length: @rows.length-1
    longest: 0
    rowsToRemove: []
    @rows.each ( (row, i) ->
      empty: row.empty() # check is the row is empty
      if empty and i isnt 0 and i isnt length
        rowsToRemove.push row
      if i is length and not empty
        @addRow @columns
    ).bind @
    rowsToRemove.each ( (item) ->
      @removeRow item
    ).bind @
  getData: ->
    ret: {}
    headers: []
    @header.cells.each (item) ->
      value: item.getValue()        
      ret[checkForKey(value,ret)]:[]
      headers.push ret[value]
    @rows.each ( (row) ->
      if not row.empty()
        row.getValue().each (item,i) ->
          headers[i].push item
    ).bind @
    ret
  getValue: ->
    @getData()
  setValue: () ->
}
Data.TableRow: new Class {
  Extends: Data.Abstract
  Delegates: {base: ['getChildren']}
  options: {
    columns: 1
    class: ''
  }
  initialize: (options) ->
    @parent options
  create: ->
    delete @base
    @base: new Element 'tr'
    @base.addClass @options.class
    @cells: []
    i: 0
    while i < @options.columns
      @add('')
      i++
  add: (value) ->
    cell: new Data.TableCell({value:value})
    cell.addEvent 'editEnd', ( ->
      @fireEvent 'editEnd'
    ).bindWithEvent @
    cell.addEvent 'next', ((cell) ->
      index: @cells.indexOf cell
      if index is @cells.length-1
        @fireEvent 'next', @
      else
        @cells[index+1].editStart()
    ).bindWithEvent @
    @cells.push cell
    @base.grab cell
  empty: ->
    filtered: @cells.filter (item) ->
      if item.getValue() isnt '' then yes else no
    if filtered.length > 0 then no else yes
  removeLast: ->
    @remove @cells.getLast()
  remove: (cell,remove)->
    cell.removeEvents 'editEnd'
    cell.removeEvents 'next'
    @cells.erase cell
    cell.base.destroy()
    delete cell
  removeAll: ->
    (@cells.filter -> true).each ( (cell) ->
      @remove cell
    ).bind @
  getValue: ->
    @cells.map (cell) ->
      cell.getValue()
}
Data.TableCell: new Class {
  Extends: Data.Abstract
  Binds: ['editStart','editEnd']
  options:{
    editable: on
    value: ''
  }
  initialize: (options) ->
    @parent options
  create: ->
    delete @base
    @base: new Element 'td', {text: @options.value}
    if @options.editable
      @base.addEvent 'click', @editStart
  editStart: ->
    if not @editing
      @editing: on
      @input: new Element 'input', {type:'text',value:@value}
      @base.set 'html', ''
      @base.grab @input
      @input.addEvent 'change', ( ->
        @setValue @input.get 'value'
      ).bindWithEvent @
      @input.addEvent 'keydown', ( (e) ->
        if e.key is 'enter'
          @input.blur()
        if e.key is 'tab'
          e.stop()
          @fireEvent 'next', @
      ).bindWithEvent @
      size: @base.getSize()
      @input.setStyles {width: size.x+"px !important",height:size.y+"px !important"}
      @input.focus()
      @input.addEvent 'blur', @editEnd
  editEnd: (e) ->
    if @editing
      @editing: off
    @setValue @input.get 'value'
    @input.removeEvents ['change','keydown']
    @input.destroy()
    delete @input
    @fireEvent 'editEnd'
  setValue: (value) ->
    @value: value
    if not @editing
      @base.set 'text', @value
  getValue: ->
    @base.get 'text'
}
