###
---

name: Interfaces.Controls

description: Some control functions.

license: MIT-style license.

requires: 

provides: Interfaces.Controls

...
###
Interfaces.Controls: new Class {
  hide: ->
    @base.setStyle 'opacity', 0
  show: -> 
    @base.setStyle 'opacity', 1
}