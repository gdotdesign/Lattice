###
---

name: Interfaces.Reflow

description: Some control functions.

license: MIT-style license.

provides: Interfaces.Reflow

requires: [GDotUI]

...
###
Interfaces.Reflow = new Class {
  Implements: Events
  createTemp: ->
    @sensor = new Element 'p'
    @sensor.setStyles {
      margin: 0,
      padding: 0,
      position: 'absolute',
      bottom: 0,
      right: 0,
      "z-index": -9999
    }
  pollReflow: ->
    @base.grab @sensor
    counter = 0  
    interval = setInterval ( ->
      if @sensor.offsetWidth > 2 or ++counter > 99
        console.log interval
        clearInterval interval
        @sensor.dispose()
        @ready()
    ).bind(@) , 20
    
}
