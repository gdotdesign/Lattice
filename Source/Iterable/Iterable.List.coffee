###
---

name: Iterable.List

description: 

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.List

...
###
Iterable.List: new Class {
  Extends:Core.Abstract
  options:{
    class: GDotUI.Theme.List.class
  }
  initialize: (options) ->
    @parent options
    this
  create: ->
    @base.addClass @options.class
    @sortable: new Sortables null, {handle:'.list-handle'}
    #TODO Sortable Events
    @editing: off
    @items: []
  removeItem: (li) ->
    li.removeEvents 'invoked', 'edit', 'delete'
    li.base.destroy()
    @items.erase li
    delete li
  removeAll: ->
    @selected: null
    @items.each( ( ->
      @removeItem item
      ).bind this)
    delete @items
    @items: []
  toggleEdit: ->
    bases: @items.map (item) ->
      return item.base
    if @editing
      @sortable.removeItems bases
      @items.each (item) ->
        item.toggleEdit()
      @editing: off
    else
      @sortable.addItems bases
      @items.each (item) ->
        item.toggleEdit()
      @editing: on
  getItemFromTitle: (title) ->
    filtered: @items.filter (item) ->
      if item.title.get('text') == String(title)
        yes
      else no
    filtered[0]
  select: (item) ->
    if @selected != item
      if @selected?
        @selected.base.removeClass 'selected'
      @selected: item
      @selected.base.addClass 'selected'
      @fireEvent 'select', item
  addItem: (li) -> 
    @items.push li
    @base.grab li
    li.addEvent 'invoked', ( (item) ->
      @select item
      @fireEvent 'invoked', [item]
      ).bindWithEvent this
    li.addEvent 'edit', ( -> 
      @fireEvent 'edit', arguments
      ).bindWithEvent this
    li.addEvent 'delete', ( ->
      @fireEvent 'delete', arguments
      ).bindWithEvent this
}
###
toTheTop:function(item){
  //console.log(item);
  //@base.setStyle('top',@base.getPosition().y-item.base.getSize().y);
  @items.erase(item);
  @items.unshift(item);
  
},
update:function(){
  @items.each(function(item,i){
    item.base.dispose();
    @base.grab(item.base,'top');
  }.bind(this))
},
###