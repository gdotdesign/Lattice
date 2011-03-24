###
---

name: Interfaces.Controls

description: Some control functions.

license: MIT-style license.

provides: Interfaces.Controls

requires: [GDotUI]

...
###
Interfaces.Controls = new Class {
  Delegates: {
    base: ['hide','show','toggle']
  }
}
