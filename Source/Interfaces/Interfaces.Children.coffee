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
  adoptChildren: ->
    children = Array.from(arguments)
    @children.append children
    @base.adopt arguments
  addChild: (el) ->
    @children.push el
    @base.grab el
}
