###
---

name: Interfaces.Children

description: 

license: MIT-style license.

requires: [GDotUI]

provides: Interfaces.Children

...
###
Interfaces.Children = new Class {
  _$Children: ->
    @children = []
  hasChild: (child) ->
    if @children.indexOf child is -1 then no else yes
  adoptChildren: ->
    children = Array.from(arguments)
    @children.append children
    @base.adopt arguments
  addChild: (el) ->
    @children.push el
    @base.grab el
  removeChild: (el) ->
    if @children.contains(el)
      @children.erease el
      el.dispose()
}
