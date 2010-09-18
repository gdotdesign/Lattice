###
---

name: GDotUI

description: G.UI

license: MIT-style license.

provides: GDotUI

...
###
Interfaces = {}
Core = {}
Data = {}
Iterable = {}
Pickers = {}
Forms = {}

if !GDotUI?
  GDotUI = {}

GDotUI.Config ={
    tipZindex: 100
    floatZindex: 0
    cookieDuration: 7*1000
}
