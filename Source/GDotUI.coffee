###
---

name: GDotUI

description: 

license: MIT-style license.

requires: 

provides: GDotUI

...
###
Interfaces: {}
Core: {}
Data: {}
Iterable: {}
Pickers: {}
Forms: {}

if !GDotUI?
  GDotUI: {}

GDotUI.Config:{
    tipZindex: 100
    floatZindex: 0
    cookieDuration: 7*1000
}
GDotUI.clone: (o) ->
  if typeof(o) isnt 'object' then o
  else if o? then o
  else
    newO: new Object()
    for i in o
        newO[i]: clone o[i]
    newO